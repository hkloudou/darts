import 'dart:async';
import 'dart:typed_data';

import 'mqtt.dart';
import 'package:dart_mqtt/dart_mqtt.dart';
import 'package:xtransport/xtransport.dart';
import 'logger_io.dart' if (dart.library.html) 'logger_html.dart' as loger;

typedef EvtMqttPublishArrived = void Function(MqttMessagePublish msg);

/// Mqtt client instance
class MqttClient {
  static MqttClient? instance;
  ITransportClient transport;
  bool _started = false;
  bool _paused = false;
  bool _stoped = false;
  bool _disposed = false;
  bool log = false;

  final _buf = MqttBuffer();
  MqttFixedHead? lasthead;

  Timer? _pinger;

  /// allow Reconnect when
  bool allowReconnect;

  /// delay before reconnect
  Duration reconnectWait;

  Duration? keepAlive;

  MqttMessageConnect get connectPacket => _connectPacket;

  /// custom reconnect delay
  Duration Function()? customReconnectDelayCB;
  final MqttMessageConnect _connectPacket = MqttMessageConnect();
  final _idTopic = <int, List<String>>{};
  final _subList = <String, MqttMessageSubscribe>{};
  final _subComplate = <String, void Function()>{};
  final _finishedSubCache = <String>{};
  final _dataArriveCallBack = <String, EvtMqttPublishArrived>{};
  //Events
  void Function(MqttMessageConnack msg)? _onMqttConack;
  Future<void> Function()? _onBeforeReconnect;
  Future<void> Function()? _onClose;

  /// set ConnectPacket ping keepaliveSecond
  MqttClient withKeepalive(int seconds) {
    keepAlive = Duration(seconds: seconds);
    _connectPacket.withKeepalive(seconds);
    return this;
  }

  /// set ConnectPacket UserName and pwd
  MqttClient withAuth(String userName, String pwd) {
    _connectPacket.withAuth(userName, pwd);
    return this;
  }

  /// set ConnectPacket clientID
  MqttClient withClientID(String clientID) {
    _connectPacket.withClientID(clientID);
    return this;
  }

  /// set ConnectPacket clearSession default:true
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
    msg.toTopic(topic);
    msg.data = payload ?? Uint8List(0);
    _send(msg);
    return Future.value();
  }

  Future<void> subscribe(
    String topic, {
    bool force = true,
    EvtMqttPublishArrived? onMessage,
    bool futureWaitData = false,
    // mqtt head
    bool retain = false,
    MqttQos qos = MqttQos.qos0,
    bool dup = false,
    Duration? timeout,
  }) {
    var com = Completer<void>();
    Timer? _timeout;
    if (timeout != null) {
      _timeout = Timer.periodic(timeout, (timer) {
        timer.cancel();
        if (!com.isCompleted) {
          com.completeError("subcribe timeout");
        }
      });
    }
    if (onMessage != null) {
      _dataArriveCallBack[topic] = onMessage;
    }
    // handle the events
    _dataArriveCallBack[topic] = (msg) {
      onMessage?.call(msg);
      //futureWaitData
      if (futureWaitData && !com.isCompleted) {
        _timeout?.cancel();
        com.complete();
      }
    };

    if (!force && _finishedSubCache.contains(topic)) {
      if (log) print("mqtt can't resub $topic when force=false");

      return futureWaitData ? com.future : Future.value();
    }
    var id = MessageIdentifierDispenser().getNextMessageIdentifier();
    // print("id $id");
    _idTopic[id] = [topic];

    var msg = MqttMessageSubscribe.withTopic(id, topic, qos);

    msg.fixedHead.retain = retain;
    msg.fixedHead.dup = dup;
    _subList[topic] = msg;
    // handle future when suback
    if (!futureWaitData) {
      _subComplate[topic] = () {
        if (!com.isCompleted) {
          _timeout?.cancel();
          com.complete();
          _subComplate.remove(topic);
        }
      };
    }
    _send(msg);
    return com.future;
  }

  Future<void> unSubscribe(String topic) async {
    _subList.remove(topic);
    _dataArriveCallBack.remove(topic);
    _finishedSubCache.remove(topic);
    var msg = MqttMessageUnSubscribe.withTopic([topic]);
    msg.withMessageID(MessageIdentifierDispenser().getNextMessageIdentifier());
    _send(msg);
    return;
  }

  /// internal function
  MqttClient._(
    this.transport, {
    // required this.credentials,
    required this.log,
    required this.allowReconnect,
    required this.reconnectWait,
    required this.customReconnectDelayCB,
  });

  MqttClient(
    ITransportClient client, {
    // XtransportCredentials credentials = const XtransportCredentials.insecure(),
    bool log = false,
    // reconnect attributes
    bool allowReconnect = false,
    Duration reconnectWait = const Duration(seconds: 2),
    Duration Function()? customReconnectDelayCB,
  }) : this._(
          client,
          // credentials: credentials,
          allowReconnect: allowReconnect,
          reconnectWait: reconnectWait,
          customReconnectDelayCB: customReconnectDelayCB,
          log: log,
        );

  /// pause (ex: when app in backgroud mode)
  void pause() {
    _paused = true;
    close("pause");
  }

  /// resume (ex:when app resume to fourcegroud mode)
  void resume() {
    _paused = false;
  }

  bool get paused => _paused;

  /// close the connect
  void close([dynamic reson = "no reson"]) {
    // print("reson: $reson");
    transport.close();
  }

  /// eliminate functionality
  void dispose() {
    _disposed = true; // to stop recursive calls of `_resetTimePeriodic()`
    stop();
  }

  void _onConnectClose() {
    if (_stoped) return; //return if stoped

    if (_paused) {
      //check 1 second later if paused
      Future.delayed(Duration(seconds: 1)).then((_) => _onConnectClose());
      return;
    }
    _onClose?.call();
    // if reconnectDuration not null, reconnect
    if (allowReconnect) {
      Future.delayed(customReconnectDelayCB?.call() ?? reconnectWait).then((_) {
        // _onBeforeReconnect?.call().th;
        if (_onBeforeReconnect != null) {
          return _onBeforeReconnect
              ?.call()
              .then((value) => transport.connect());
        } else {
          transport.connect();
        }
      });
    }
  }

  void _resetTimePeriodic() {
    if(_disposed) return; // to stop recursive calls of `_resetTimePeriodic()`

    if (transport.status != ConnectStatus.connected) {
      loger.log("_resetTimePeriodic: ${transport.status}");
    }
    var _seconds = _connectPacket.getKeepalive();
    // _seconds = (_seconds * 0.5).toInt();
    _pinger?.cancel();
    if (_seconds > 0) {
      _pinger = Timer(Duration(seconds: _seconds), () {
        _send(MqttMessagePingreq());
        _resetTimePeriodic();
      });
    }
  }

  void _send(ITransportPacket obj) {
    // if (log) print("mqtt:ready send\n$obj");

    if (_stoped) return;
    if (_paused) return;
    if (transport.status != ConnectStatus.connected) {
      loger.log("_conn.status != ConnectStatus.connected: ${transport.status}");
      // developer.log(obj.toString());
      return;
    }
    // if (obj.)
    // _resetTimePeriodic();
    // print("send");
    transport.send(obj);
// log(message);

    if (log) {
      // Console.setTextColor(2);
      // Console.write("xx");
      // print(r'\e[1;31mRed text here\e[m normal text here');
      //\u001b[39;2m${DateTime.now().toString().substring(5)}\u001b[0m
      loger.log(
        "\u001b[32m↑\u001b[0m $obj",
        name: "mqtt",
      );
    }
  }

  void reSub() {
    if (log) {
      loger.log("resub topics: ${_subList.keys.toList()}", name: "mqtt");
    }
    _subList.forEach((key, value) {
      var id = MessageIdentifierDispenser().getNextMessageIdentifier();
      _idTopic[id] = _subList[key]!.topics;
      _subList[key]!.withMessageID(id);
      // log(message)
      _send(_subList[key]!);
    });
  }

  /// start connect
  void start() {
    if (_stoped) return;
    if (_started) return; //once function
    _started = true;
    //register events
    transport.onConnect(() {
      _buf.clear();
      lasthead = null;
      _idTopic.clear();
      _finishedSubCache.clear();
      MessageIdentifierDispenser().reset();
      _resetTimePeriodic();
      _send(_connectPacket);
    });
    transport.onClose(() {
      _onConnectClose();
    });
    transport.onMessage((msg) {
      _buf.addAll(msg.message);
      while(_buf.availableBytes > 0){
        late MqttMessage pack;
        if (lasthead != null) {
          if (_buf.availableBytes < lasthead!.remainingLength) {
            // continue wait
            return;
          }
          try {
            _buf.shrink();
            pack = MqttMessageFactory.readMessage(lasthead!,
                MqttBuffer.fromList(_buf.read(lasthead!.remainingLength)));
            lasthead = null;
          } on Exception catch (e) {
            lasthead = null;
            loger.log("\u001b[31m$e\u001b[0m");
            close(e);
            return;
          }
        } else {
          var head = MqttMessageFactory.readHead(_buf);
          if (_buf.availableBytes < head.remainingLength) {
            lasthead = head;
            return;
          }
          try {
            _buf.shrink();
            pack = MqttMessageFactory.readMessage(
                head, MqttBuffer.fromList(_buf.read(head.remainingLength)));
            _buf.shrink();
          } on Exception catch (e) {
            loger.log("\u001b[31m$e\u001b[0m");
            close(e);
            return;
          }
        }

        if (log) {
          loger.log("\u001b[31m↓\u001b[0m ${pack.toString()}", name: "mqtt");
        }
        switch (pack.fixedHead.messageType) {
          case MqttMessageType.connack:
            _onMqttConack?.call(pack as MqttMessageConnack);
            if (_onMqttConack == null &&
                (pack as MqttMessageConnack).returnCode !=
                    MqttConnectReturnCode.connectionAccepted) {
              // _conn.close();
              close((pack).returnCode);
            }
            break;
          case MqttMessageType.suback:
            var obj = pack as MqttMessageSuback;
            if (_idTopic.containsKey(obj.msgid)) {
              var _topics = _idTopic[obj.msgid]!;
              // print("this topic: $_topics");
              _idTopic.remove(obj.msgid);
              for (var _topic in _topics) {
                _finishedSubCache.add(_topic);
                _subComplate[_topic]?.call();
              }
            }
            break;
          case MqttMessageType.publish:
            var obj = pack as MqttMessagePublish;
            final wildcardKeys = _dataArriveCallBack.keys.where((key) =>
              key.split('#').length == 2,
            ).map((key) =>
              key.split('#').first,
            ).where((key) =>
              obj.topicName.startsWith(key),
            ).firstOrNull;
            if (wildcardKeys != null) {
              _dataArriveCallBack['${wildcardKeys}#']?.call(obj);
            } else {
              _dataArriveCallBack[obj.topicName]?.call(obj);
            }
            break;
          default:
        }
      }
    });
    transport.connect(deadline: keepAlive);
  }

  /// stop this client
  void stop() {
    _stoped = true;
    pause();
  }
}
