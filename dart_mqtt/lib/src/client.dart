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
  final _pendingPubacks = <int, Completer<void>>{};
  final _midDispenser = MessageIdentifierDispenser();
  bool _closeHandled = false;

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

  /// Publish a message to [topic].
  ///
  /// For QoS 1 and above the returned future completes when the broker
  /// acknowledges the message with PUBACK, or when the connection drops
  /// before the acknowledgment arrives.
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
    msg.toTopic(topic);
    msg.data = payload ?? Uint8List(0);
    if (qos != MqttQos.qos0) {
      msg.msgid = _midDispenser.getNextMessageIdentifier();
      if (!_stopped && !_paused && transport.status == ConnectStatus.connected) {
        final com = Completer<void>();
        _pendingPubacks[msg.msgid] = com;
        _send(msg);
        return com.future;
      }
      // _send() drops the packet in these states; complete immediately
      // rather than returning a future that can never finish.
    }
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

    if (onMessage != null) {
      _dataArriveCallBack[topic] = onMessage;
    }

    var id = _midDispenser.getNextMessageIdentifier();
    _idTopic[id] = [topic];

    var msg = MqttMessageSubscribe.withTopic(id, topic, qos);
    msg.fixedHead.retain = retain;
    msg.fixedHead.dup = dup;
    _subList[topic] = msg;

    if (timeout != null) {
      timer = Timer(timeout, () {
        if (!com.isCompleted) {
          _subComplete.remove(topic);
          _idTopic.remove(id);
          com.completeError(TimeoutException(
              'dart_mqtt: subscribe timeout: $topic', timeout));
        }
      });
    }

    _subComplete[topic] = () {
      _subComplete.remove(topic);
      timer?.cancel();
      if (!com.isCompleted) {
        com.complete();
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
      // Send DISCONNECT directly: _send() would silently drop it when the
      // client is already flagged paused/stopped — precisely the states
      // that trigger a graceful shutdown.
      final msg = MqttMessageDisconnect();
      try {
        transport.send(msg);
        if (log) {
          loger.log("\u001b[32m↑\u001b[0m $msg", name: "mqtt");
        }
      } catch (_) {
        // The socket may already be broken; proceed with the close.
      }
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
    _releasePendingPubacks();
    if (_stopped) return;

    if (_paused) {
      Future.delayed(const Duration(seconds: 1)).then((_) => _onConnectClose());
      return;
    }
    // The transport can report a single disconnect through both onError and
    // onClose; handle it once per connection.
    if (_closeHandled) return;
    _closeHandled = true;
    _onClose?.call();
    if (allowReconnect) {
      Future.delayed(customReconnectDelayCB?.call() ?? reconnectWait).then((_) {
        if (_stopped || _disposed) return;
        _closeHandled = false;
        if (_onBeforeReconnect != null) {
          _onBeforeReconnect?.call().then((value) => transport.connect());
        } else {
          transport.connect();
        }
      });
    }
  }

  void _releasePendingPubacks() {
    if (_pendingPubacks.isEmpty) return;
    final pending = _pendingPubacks.values.toList();
    _pendingPubacks.clear();
    for (final com in pending) {
      if (!com.isCompleted) {
        com.complete();
      }
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
      loger.log("resub topics: ${_subList.keys.join(', ')}", name: "mqtt");
    }
    _subList.forEach((key, value) {
      var id = _midDispenser.getNextMessageIdentifier();
      _idTopic[id] = value.topics;
      value.withMessageID(id);
      _send(value);
    });
  }

  /// Start the client connection
  void start() {
    if (_stopped) return;
    if (_started) return;
    _started = true;

    transport.onConnect(() {
      _closeHandled = false;
      _buf.clear();
      _idTopic.clear();
      _midDispenser.reset();
      _resetTimePeriodic();
      _send(_connectPacket);
    });
    transport.onClose(() {
      _onConnectClose();
    });
    transport.onError((err) {
      // A failed connect attempt reports only onError (never onClose);
      // without this handler a single failed reconnect ends the retry loop.
      if (log) {
        loger.log("\u001b[31mtransport error: ${err.errMsg}\u001b[0m",
            name: "mqtt");
      }
      _onConnectClose();
    });
    transport.onMessage((msg) {
      _buf.rewind();
      _buf.addAll(msg.message);
      while (_buf.availableBytes >= 2) {
        final packetStart = _buf.offset;
        MqttFixedHead head;
        MqttMessage pack;

        try {
          head = MqttMessageFactory.readHead(_buf);
        } on MqttIncompleteMessageException {
          _buf.seek(packetStart);
          break; // Incomplete header, wait for more data
        } on Exception catch (e) {
          if (e.toString().contains('Unexpected end of buffer')) {
            _buf.seek(packetStart);
            break; // Incomplete header, wait for more data
          }
          // Malformed packet, close connection
          loger.log("\u001b[31m$e\u001b[0m");
          close(e);
          return;
        }

        if (_buf.availableBytes < head.remainingLength) {
          _buf.seek(packetStart);
          break; // Incomplete body, wait for more data
        }

        try {
          pack = MqttMessageFactory.readMessage(
              head, MqttBuffer.fromList(_buf.read(head.remainingLength)));
        } on Exception catch (e) {
          loger.log("\u001b[31m$e\u001b[0m");
          close(e);
          return;
        }

        try {
          _handleMqttMessage(pack);
        } catch (e) {
          // A throwing user callback must not kill the connection or stall
          // the packets already buffered behind this one.
          loger.log(
              "\u001b[31mdart_mqtt: message handler threw: $e\u001b[0m",
              name: "mqtt");
        }
      }
      // Consume all fully parsed packets in one pass; a trailing partial
      // packet (cursor moved back above) stays for the next data event.
      _buf.shrink();
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
        final topics = _idTopic.remove(obj.msgid);
        if (topics != null) {
          for (var topic in topics) {
            _subComplete[topic]?.call();
          }
        }
        break;
      case MqttMessageType.puback:
        final obj = message as MqttMessagePuback;
        final com = _pendingPubacks.remove(obj.msgid);
        if (com != null && !com.isCompleted) {
          com.complete();
        }
        break;
      case MqttMessageType.publish:
        var obj = message as MqttMessagePublish;
        final exact = _dataArriveCallBack[obj.topicName];
        if (exact != null) {
          exact(obj);
        } else {
          final topicParts = obj.topicName.split('/');
          for (final entry in _dataArriveCallBack.entries) {
            if (_topicMatch(entry.key, topicParts)) {
              entry.value(obj);
              break;
            }
          }
        }
        break;
      default:
    }
  }

  /// MQTT topic matching per spec section 4.7; [topicParts] is the topic
  /// name pre-split on '/' so a burst of filters shares one split.
  static bool _topicMatch(String filter, List<String> topicParts) {
    final filterParts = filter.split('/');
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
