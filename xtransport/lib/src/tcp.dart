import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:xtransport/src/interface.dart';
import 'package:xtransport/src/jsons.dart';

import 'logger_io.dart' if (dart.library.html) 'logger_html.dart' as loger;
import 'package:xtransport/src/shared/credentials.dart';

class XTransportTcpClient implements ITransportClient {
  /*
    interface fields 
  */
  @override
  XtransportCredentials credentials = const XtransportCredentials.insecure();

  @override
  ConnectStatus status = ConnectStatus.disconnect;

  @override
  bool log = false;

  String _ip;
  int _port;
  Socket? _socket;
  Duration? _deadline;
  Duration _duration = Duration(seconds: 20);

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
      _socket?.add(obj.pack());
    } catch (e) {
      loger.log(
        "send data",
        name: "tcp",
        error: e,
      );
      // _onError?.call(XTransportError.from(e));
      close();
    }
  }

  @override
  void close() {
    _socket?.close();
    if (log) {}
    loger.log(
      "\u001b[31m${"closed"}\u001b[0m",
      time: DateTime.now(),
      name: "tcp",
    );
    _socket?.destroy();
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

  XTransportTcpClient.from(
    this._ip,
    this._port, {
    this.log = false,
    this.credentials = const XtransportCredentials.insecure(),
  })  : assert(Uri.parse("tcp://$_ip").host == _ip),
        assert(_port > 0 && _port < 65536);

  Future<Socket> getConnectionSocket({Duration? duration}) async {
    var _tmpSocket = await Socket.connect(_ip, _port,
        timeout: duration ?? const Duration(seconds: 60));
    if (_tmpSocket.address.type != InternetAddressType.unix) {
      _tmpSocket.setOption(SocketOption.tcpNoDelay, true);
    }

    if (credentials.isSecure) {
      // Todo(sigurdm): We want to pass supportedProtocols: ['h2'].
      // http://dartbug.com/37950
      return await SecureSocket.secure(
        _tmpSocket,
        host: credentials.authority ?? _ip,
        context: credentials.securityContext,
        onBadCertificate: (cert) {
          if (credentials.onBadCertificate != null) {
            return credentials.onBadCertificate!(
              cert,
              credentials.authority ?? _ip,
            );
          }
          return false;
        },
      );
    }
    return _tmpSocket;
  }

  /// [TCP] connect
  @override
  Future<void> connect(
      {String? host, int? port, Duration? duration, Duration? deadline}) async {
    if (log) {
      loger.log(
        "\u001b[32m${"connecting"}\u001b[0m",
        time: DateTime.now(),
        name: "tcp",
      );
    }
    _ip = host ?? _ip;
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
        address: _socket?.remoteAddress.address ?? "",
        host: (credentials.isSecure ? credentials.authority : null) ??
            _socket?.remoteAddress.host ??
            "",
        port: _port,
        family: _socket?.remoteAddress.type.name ?? "",
      );
      _localInfo = LocalInfo(
        address: _localInfo.address,
        family: _socket?.address.type.name ?? "",
        port: _socket?.port ?? 0,
      );
      status = ConnectStatus.connected;
      _onConnect?.call();
    } catch (e) {
      loger.log(
        "connect",
        error: e,
        name: "tcp",
      );
      status = ConnectStatus.disconnect;
      _onError?.call(XTransportError.from(e));
      // Remove _onClose call here - connection was never established
      return Future.value();
    }
    _broadcastNotifications(deadline: _deadline);
    return Future.value();
  }

  /// internal function
  Future<StreamSubscription<Uint8List>> _broadcastNotifications(
      {Duration? deadline}) async {
    Stream<Uint8List>? _sub = _socket;
    if (deadline != null) {
      _sub = _socket?.timeout(
        deadline * 1.5,
        onTimeout: (sink) {
          close();
        },
      );
    }
    var ret = _sub?.listen(
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
        loger.log("onDone", name: "tcp");
        status = ConnectStatus.disconnect;
        _onClose?.call();
      },
      onError: (e) {
        loger.log("onError", name: "tcp", error: e);
        status = ConnectStatus.disconnect;
        _onError?.call(XTransportError.from(e));
        _onClose?.call();
      },
      cancelOnError: true,
    );

    return Future.value(ret);
  }
}
