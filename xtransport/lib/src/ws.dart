import 'dart:async';
// import 'dart:html';
import 'dart:io';
// import 'package:logging';
import 'package:xtransport/src/interface.dart';
import 'package:xtransport/src/jsons.dart';
import 'package:xtransport/src/shared/credentials.dart';
// import 'dart:developer' as developer;
import './logger.dart' as loger;

/// XTransportWsClient
/// XTransportWsClient.from(host,path,port)
class XTransportWsClient implements ITransportClient {
  /*
    interface fields 
  */
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

  /// websocket protocols, in mqtt,it should contain mqtt
  Iterable<String>? protocols;

  RemoteInfo _remoteInfo = RemoteInfo();
  LocalInfo _localInfo = LocalInfo();

  //Events
  void Function()? _onConnect;
  void Function()? _onClose;
  void Function(Error err)? _onError;
  void Function(Message msg)? _onMessage;

  //Method
  @override
  void send(ITransportPacket obj) {
    try {
      _socket?.add(obj.pack());
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
  void onError(void Function(Error err) fn) => _onError = fn;

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
    HttpClient? customCient;
    if (credentials.isSecure) {
      customCient = HttpClient(context: credentials.securityContext);
      customCient.badCertificateCallback = (cert, host, port) {
        if (credentials.onBadCertificate != null) {
          return credentials.onBadCertificate!(
            cert,
            credentials.authority ?? _host,
          );
        }
        return false;
      };
    }
    if (log) {
      loger.log(
        "${credentials.isSecure ? "wss" : "ws"}://$_host:$_port$_path",
        name: "ws",
      );
    }
    // var channel = IOWebSocketChannel.connect(Uri.parse('ws://localhost:1234'));
    // channel.stream.listen((event) { })
    var _tmpSocket = await WebSocket.connect(
      "${credentials.isSecure ? "wss" : "ws"}://$_host:$_port$_path",
      protocols: protocols,
      // headers: {
      //   "host": credentials.authority,
      // },
      customClient: customCient,
    );

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
      status = ConnectStatus.connected;
      _onConnect?.call();
    } catch (e) {
      if (log) loger.log("connect error: $e", name: "ws");
      status = ConnectStatus.disconnect;
      _onError?.call(Error.from(e));
      _onClose?.call();
      return Future.value();
    }
    _socket?.pingInterval = deadline;
    _broadcastNotifications();
    return Future.value();
  }

  /// internal function
  Future<StreamSubscription<dynamic>?> _broadcastNotifications() async {
    var ret = _socket?.listen(
      (streamData) {
        _onMessage?.call(Message(
            message: streamData,
            remoteInfo: RemoteInfo(
              address: _remoteInfo.address,
              host: _remoteInfo.host,
              port: _remoteInfo.port,
              family: _remoteInfo.family,
              size: streamData.length,
            ),
            localInfo: _localInfo));
      },
      onDone: () {
        if (log) loger.log("onDone", name: "ws");
        status = ConnectStatus.disconnect;
        _onClose?.call();
      },
      onError: (e) {
        if (log) loger.log("onError", name: "ws", error: e);
        status = ConnectStatus.disconnect;
        _onError?.call(Error.from(e));
        // _onClose?.call();
      },
      cancelOnError: true,
    );

    return Future.value(ret);
  }
}
