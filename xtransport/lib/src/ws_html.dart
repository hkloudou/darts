import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:xtransport/src/interface.dart';
import 'package:xtransport/src/jsons.dart';
import 'package:xtransport/src/shared/credentials.dart';

import 'logger_html.dart' as loger;

class XTransportWsClient implements ITransportClient {
  @override
  XtransportCredentials credentials = const XtransportCredentials.insecure();

  @override
  ConnectStatus status = ConnectStatus.disconnect;

  @override
  bool log = false;

  String _host;
  final String _path;
  int _port;
  WebSocket? _socket;
  Duration? _deadline;
  Duration _duration = Duration(seconds: 20);

  Iterable<String>? protocols;

  RemoteInfo _remoteInfo = RemoteInfo();
  LocalInfo _localInfo = LocalInfo();

  //Events
  void Function()? _onConnect;
  void Function()? _onClose;
  void Function(XTransportError err)? _onError;
  void Function(Message msg)? _onMessage;

  //Method
  @override
  void send(ITransportPacket obj) {
    try {
      _socket?.sendTypedData(obj.pack());
    } catch (e) {
      if (log) {
        loger.log(
          "send data",
          name: "ws",
          error: e,
        );
      }
      close();
    }
  }

  @override
  void close() {
    if (log) {
      loger.log("\u001b[31m${"closed"}\u001b[0m", name: "ws");
    }
    _socket?.close();
  }

  // Events
  @override
  void onClose(void Function() fn) => _onClose = fn;

  @override
  void onConnect(void Function() fn) => _onConnect = fn;

  @override
  void onError(void Function(XTransportError err) fn) => _onError = fn;

  @override
  void onMessage(void Function(Message msg) fn) => _onMessage = fn;

  XTransportWsClient.from(
    this._host,
    this._path,
    this._port, {
    this.log = false,
    this.protocols,
    this.credentials = const XtransportCredentials.insecure(),
  })  : assert(Uri.parse("https://$_host").host == _host),
        assert(_path.startsWith("/")),
        assert(_port > 0 && _port < 65536);

  Future<WebSocket> getConnectionSocket({Duration? duration}) async {
    if (log) {
      loger.log(
        "${credentials.isSecure ? "wss" : "ws"}://$_host:$_port$_path",
        name: "ws",
      );
    }
    var _tmpSocket = WebSocket(
      "${credentials.isSecure ? "wss" : "ws"}://$_host:$_port$_path",
      protocols?.toList(),
    );

    // credentials.isSecure ? Sec
    // Web

    return _tmpSocket;
  }

  /// [WS] connect
  @override
  Future<void> connect(
      {String? host, int? port, Duration? duration, Duration? deadline}) async {
    if (log) {
      loger.log(
        "\u001b[32m${"connecting"}\u001b[0m",
        name: "ws",
      );
    }
    _host = host ?? _host;
    _port = port ?? _port;
    _duration = duration ?? _duration;
    _deadline = deadline ?? _deadline;

    if (status != ConnectStatus.disconnect) {
      return Future.value();
    }
    status = ConnectStatus.connecting;
    try {
      cancelSubscriptions();
      _socket = await getConnectionSocket(duration: duration);
      _remoteInfo = RemoteInfo(
        address: "${credentials.isSecure ? "wss" : "ws"}://$_host:$_port$_path",
        host: _host,
        port: _port,
        family: credentials.isSecure ? "wss" : "ws",
      );
      _localInfo = LocalInfo(
        address: _localInfo.address,
        family: credentials.isSecure ? "wss" : "ws",
        port: _port,
      );
      _initializeWebSocketEvents();
    } catch (e) {
      if (log) loger.log("connect error: $e", name: "ws");
      status = ConnectStatus.disconnect;
      _onError?.call(XTransportError.from(e));
      _onClose?.call();
      return Future.value();
    }
    return Future.value();
  }

  StreamSubscription? _onOpenSubscription;
  StreamSubscription? _onMessageSubscription;
  StreamSubscription? _onCloseSubscription;
  StreamSubscription? _onErrorSubscription;

  void _initializeWebSocketEvents() {
    if (_socket == null) return;

    _socket?.onOpen.listen((event) {
      _onConnect?.call();
    });

    _onMessageSubscription = _socket?.onMessage.listen((MessageEvent event) {
      Uint8List message = Uint8List.fromList([]);
      if (event.data is ByteBuffer) {
        ByteBuffer buffer = event.data as ByteBuffer;
        message = Uint8List.view(buffer);
      } else if (event.data is String) {
        String strData = event.data as String;
        List<int> list = utf8.encode(strData);
        message = Uint8List.fromList(list);
      } else if (event.data is Blob) {
        blobToUint8List(event.data).then(
          (value) => _onMessage?.call(
            Message(
                message: value,
                remoteInfo: RemoteInfo(
                  address: _remoteInfo.address,
                  host: _remoteInfo.host,
                  port: _remoteInfo.port,
                  family: _remoteInfo.family,
                  size: value.length,
                ),
                localInfo: _localInfo),
          ),
        );
        return;
      } else {
        // typof
        print("error fotmat${event.data.runtimeType}");
        // Handle other types of data or errors
        return;
      }
      _onMessage?.call(Message(
          message: message,
          remoteInfo: RemoteInfo(
            address: _remoteInfo.address,
            host: _remoteInfo.host,
            port: _remoteInfo.port,
            family: _remoteInfo.family,
            size: message.length,
          ),
          localInfo: _localInfo));
    });

    _onCloseSubscription = _socket?.onClose.listen((event) {
      if (log) loger.log("onDone", name: "ws");
      status = ConnectStatus.disconnect;
      // _socket.removeEventListener(type, (event) => null)
      cancelSubscriptions();
      _onClose?.call();
    });

    _onErrorSubscription = _socket?.onError.listen((e) {
      if (log) loger.log("onError", name: "ws", error: e.toString());
      status = ConnectStatus.disconnect;
      _onError?.call(XTransportError.from(e));
    });
    _onOpenSubscription = _socket?.onOpen.listen((e) {
      status = ConnectStatus.connected;
      _onConnect?.call();
    });
  }

  void cancelSubscriptions() {
    _onOpenSubscription?.cancel();
    _onMessageSubscription?.cancel();
    _onCloseSubscription?.cancel();
    _onErrorSubscription?.cancel();
  }
}

Future<Uint8List> blobToUint8List(Blob blob) async {
  FileReader reader = FileReader();
  reader.readAsArrayBuffer(blob);

  Completer<Uint8List> completer = Completer<Uint8List>();

  reader.onLoadEnd.listen((_) {
    if (reader.readyState == FileReader.DONE) {
      // Check if the result is already a Uint8List
      if (reader.result is Uint8List) {
        completer.complete(reader.result as Uint8List);
      } else if (reader.result is ByteBuffer) {
        // If the result is a ByteBuffer, convert it to Uint8List
        ByteBuffer buffer = reader.result as ByteBuffer;
        Uint8List uint8List = Uint8List.view(buffer);
        completer.complete(uint8List);
      } else {
        // If the result is neither, complete with an error
        completer.completeError(StateError('Unexpected result type'));
      }
    }
  });

  reader.onError.listen((event) {
    completer.completeError(event);
  });

  return completer.future;
}
