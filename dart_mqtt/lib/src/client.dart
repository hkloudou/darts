import 'dart:async';
import 'dart:typed_data';

import 'mqtt.dart';
import 'utility/dart_mqtt_enum.dart';
import 'package:xtransport/xtransport.dart';
import 'logger_io.dart' if (dart.library.html) 'logger_html.dart' as loger;

typedef EvtMqttPublishArrived = void Function(MqttMessagePublish msg);

/// Mqtt client instance
class MqttClient {
  ITransportClient transport;
  bool _started = false;
  bool _paused = false;
  bool _stopped = false;
  bool _disposed = false;
  bool log = false;

  final _buf = MqttBuffer();

  Timer? _pinger;

  /// Allow reconnect on disconnect
  bool allowReconnect;

  /// Delay before reconnect attempt
  Duration reconnectWait;

  Duration? keepAlive;

  MqttMessageConnect get connectPacket => _connectPacket;

  /// Custom reconnect delay callback
  Duration Function()? customReconnectDelayCB;
  final MqttMessageConnect _connectPacket = MqttMessageConnect();
  final _idTopic = <int, List<String>>{};
  final _subList = <String, MqttMessageSubscribe>{};
  final _subComplete = <String, void Function()>{};
  final _dataArriveCallBack = <String, EvtMqttPublishArrived>{};
  final _midDispenser = MessageIdentifierDispenser();

  // Events
  void Function(MqttMessageConnack msg)? _onMqttConack;
  Future<void> Function()? _onBeforeReconnect;
  Future<void> Function()? _onClose;

  /// Set keepalive interval in seconds
  MqttClient withKeepalive(int seconds) {
    keepAlive = Duration(seconds: seconds);
    _connectPacket.withKeepalive(seconds);
    return this;
  }

  /// Set authentication credentials
  MqttClient withAuth(String userName, String pwd) {
    _connectPacket.withAuth(userName, pwd);
    return this;
  }

  /// Set client ID
  MqttClient withClientID(String clientID) {
    _connectPacket.withClientID(clientID);
    return this;
  }

  /// Set clean session flag (default: true)
  MqttClient withClearSession(bool clear) {
    _connectPacket.cleanStart = clear;
    return this;
  }

  void onBeforeReconnect(Future<void> Function()? fn) =>
      _onBeforeReconnect = fn;
  void onClose(Future<void> Function()? fn) => _onClose = fn;
  void onMqttConack(void Function(MqttMessageConnack msg)? fn) =>
      _onMqttConack = fn;

  Future<void> publish(
    String topic, {
    bool retain = false,
    MqttQos qos = MqttQos.qos0,
    bool dup = false,
    Uint8List? payload,
  }) {
    var msg = MqttMessagePublish();
    msg.fixedHead.retain = retain;
    msg.fixedHead.qos = qos;
    msg.fixedHead.dup = dup;
    if (qos != MqttQos.qos0) {
      msg.msgid = _midDispenser.getNextMessageIdentifier();
    }
    msg.toTopic(topic);
    msg.data = payload ?? Uint8List(0);
    _send(msg);
    return Future.value();
  }

  /// Subscribe to a topic. Returns a Future that completes when SUBACK is
  /// received (or when [timeout] expires with an error).
  Future<void> subscribe(
    String topic, {
    EvtMqttPublishArrived? onMessage,
    bool retain = false,
    MqttQos qos = MqttQos.qos0,
    bool dup = false,
    Duration? timeout,
  }) {
    final com = Completer<void>();
    Timer? timer;
    if (timeout != null) {
      timer = Timer(timeout, () {
        if (!com.isCompleted) {
          com.completeError("subscribe timeout");
        }
      });
    }

    if (onMessage != null) {
      _dataArriveCallBack[topic] = onMessage;
    }

    var id = _midDispenser.getNextMessageIdentifier();
    _idTopic[id] = [topic];

    var msg = MqttMessageSubscribe.withTopic(id, topic, qos);
    msg.fixedHead.retain = retain;
    msg.fixedHead.dup = dup;
    _subList[topic] = msg;

    _subComplete[topic] = () {
      if (!com.isCompleted) {
        timer?.cancel();
        com.complete();
        _subComplete.remove(topic);
      }
    };

    _send(msg);
    return com.future;
  }

  Future<void> unSubscribe(String topic) async {
    _subList.remove(topic);
    _dataArriveCallBack.remove(topic);
    var msg = MqttMessageUnSubscribe.withTopic([topic]);
    msg.withMessageID(_midDispenser.getNextMessageIdentifier());
    _send(msg);
  }

  /// Internal constructor
  MqttClient._(
    this.transport, {
    required this.log,
    required this.allowReconnect,
    required this.reconnectWait,
    required this.customReconnectDelayCB,
  });

  MqttClient(
    ITransportClient client, {
    bool log = false,
    bool allowReconnect = false,
    Duration reconnectWait = const Duration(seconds: 2),
    Duration Function()? customReconnectDelayCB,
  }) : this._(
          client,
          allowReconnect: allowReconnect,
          reconnectWait: reconnectWait,
          customReconnectDelayCB: customReconnectDelayCB,
          log: log,
        );

  /// Pause the client (e.g. when app enters background)
  void pause() {
    _paused = true;
    close("pause");
  }

  /// Resume the client (e.g. when app enters foreground)
  void resume() {
    _paused = false;
  }

  bool get paused => _paused;

  /// Close the connection (sends DISCONNECT first if connected)
  void close([dynamic reason = "no reason"]) {
    _pinger?.cancel();
    if (transport.status == ConnectStatus.connected) {
      _send(MqttMessageDisconnect());
    }
    transport.close();
  }

  /// Dispose the client permanently
  void dispose() {
    _disposed = true;
    stop();
  }

  void _onConnectClose() {
    _pinger?.cancel();
    if (_stopped) return;

    if (_paused) {
      Future.delayed(const Duration(seconds: 1)).then((_) => _onConnectClose());
      return;
    }
    _onClose?.call();
    if (allowReconnect) {
      Future.delayed(customReconnectDelayCB?.call() ?? reconnectWait).then((_) {
        if (_stopped || _disposed) return;
        if (_onBeforeReconnect != null) {
          _onBeforeReconnect?.call().then((value) => transport.connect());
        } else {
          transport.connect();
        }
      });
    }
  }

  void _resetTimePeriodic() {
    if (_disposed || _stopped) return;
    if (transport.status != ConnectStatus.connected) return;
    var seconds = _connectPacket.getKeepalive();
    _pinger?.cancel();
    if (seconds > 0) {
      _pinger = Timer(Duration(seconds: seconds), () {
        _send(MqttMessagePingreq());
        _resetTimePeriodic();
      });
    }
  }

  void _send(ITransportPacket obj) {
    if (_stopped) return;
    if (_paused) return;
    if (transport.status != ConnectStatus.connected) {
      loger.log("_send: not connected (${transport.status})");
      return;
    }
    transport.send(obj);
    if (log) {
      loger.log("\u001b[32m↑\u001b[0m $obj", name: "mqtt");
    }
  }

  /// Re-subscribe all previously subscribed topics (call after reconnect)
  void reSub() {
    if (log) {
      loger.log("resub topics: ${_subList.keys.toList()}", name: "mqtt");
    }
    _subList.forEach((key, value) {
      var id = _midDispenser.getNextMessageIdentifier();
      _idTopic[id] = _subList[key]!.topics;
      _subList[key]!.withMessageID(id);
      _send(_subList[key]!);
    });
  }

  /// Start the client connection
  void start() {
    if (_stopped) return;
    if (_started) return;
    _started = true;

    transport.onConnect(() {
      _buf.clear();
      _idTopic.clear();
      _subComplete.clear();
      _midDispenser.reset();
      _resetTimePeriodic();
      _send(_connectPacket);
    });
    transport.onClose(() {
      _onConnectClose();
    });
    transport.onMessage((msg) {
      _buf.rewind();
      _buf.addAll(msg.message);
      while (_buf.availableBytes > 0) {
        late MqttFixedHead head;
        late MqttMessage pack;

        if (_buf.availableBytes < 2) {
          return;
        }

        try {
          head = MqttMessageFactory.readHead(_buf);
        } on Exception catch (e) {
          if (e.toString().contains('Unexpected end of buffer')) {
            return; // Incomplete header, wait for more data
          }
          // Malformed packet, close connection
          loger.log("\u001b[31m$e\u001b[0m");
          close(e);
          return;
        }

        if (_buf.availableBytes < head.remainingLength) {
          return;
        }

        try {
          pack = MqttMessageFactory.readMessage(
              head, MqttBuffer.fromList(_buf.read(head.remainingLength)));
          _buf.shrink();
        } on Exception catch (e) {
          loger.log("\u001b[31m$e\u001b[0m");
          close(e);
          return;
        }

        _handleMqttMessage(pack);
      }
    });
    transport.connect(deadline: keepAlive);
  }

  void _handleMqttMessage(MqttMessage message) {
    if (log) {
      loger.log("\u001b[31m↓\u001b[0m ${message.toString()}", name: "mqtt");
    }

    switch (message.fixedHead.messageType) {
      case MqttMessageType.connack:
        final connack = message as MqttMessageConnack;
        _onMqttConack?.call(connack);
        if (connack.returnCode == MqttConnectReturnCode.connectionAccepted) {
          reSub();
        } else if (_onMqttConack == null) {
          close(connack.returnCode);
        }
        break;
      case MqttMessageType.suback:
        var obj = message as MqttMessageSuback;
        if (_idTopic.containsKey(obj.msgid)) {
          var topics = _idTopic[obj.msgid]!;
          _idTopic.remove(obj.msgid);
          for (var topic in topics) {
            _subComplete[topic]?.call();
          }
        }
        break;
      case MqttMessageType.publish:
        var obj = message as MqttMessagePublish;
        if (_dataArriveCallBack.containsKey(obj.topicName)) {
          _dataArriveCallBack[obj.topicName]?.call(obj);
        } else {
          final matchedKey = _dataArriveCallBack.keys
              .where((key) => _topicMatch(key, obj.topicName))
              .firstOrNull;
          if (matchedKey != null) {
            _dataArriveCallBack[matchedKey]?.call(obj);
          }
        }
        break;
      default:
    }
  }

  /// MQTT topic matching per spec section 4.7
  static bool _topicMatch(String filter, String topic) {
    if (filter == topic) return true;
    final filterParts = filter.split('/');
    final topicParts = topic.split('/');
    for (var i = 0; i < filterParts.length; i++) {
      if (filterParts[i] == '#') {
        return true;
      }
      if (i >= topicParts.length) return false;
      if (filterParts[i] != '+' && filterParts[i] != topicParts[i]) {
        return false;
      }
    }
    return filterParts.length == topicParts.length;
  }

  /// Stop the client
  void stop() {
    _stopped = true;
    pause();
  }
}
