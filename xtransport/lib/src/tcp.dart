import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:xtransport/src/interface.dart';
import 'package:xtransport/src/jsons.dart';
import 'package:xtransport/src/shared/credentials.dart';

class XTransportTcpClient implements ITransportClient {
  /*
    interface fields 
  */
  @override
  XtransportCredentials credentials = const XtransportCredentials.insecure();

  @override
  ConnectStatus status = ConnectStatus.disconnect;

  String _host;
  int _port;
  Socket? _socket;

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
      // print("send2 $obj");
      _socket?.add(obj.pack());
      // _socket?.flush();
      // throw Exception("tt");
    } catch (e) {
      // print("err : $e");
      // _onError?.call(Error.from(e));
      // close();
    }
  }

  @override
  void close() {
    // _socket?.close();
    _socket?.destroy();
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

  XTransportTcpClient.from(this._host, this._port,
      {this.credentials = const XtransportCredentials.insecure()});

  Future<Socket> getConnectionSocket() async {
    var _tmpSocket =
        await Socket.connect(_host, _port, timeout: const Duration(seconds: 1));
    if (_tmpSocket.address.type != InternetAddressType.unix) {
      _tmpSocket.setOption(SocketOption.tcpNoDelay, true);
    }

    if (credentials.isSecure) {
      // Todo(sigurdm): We want to pass supportedProtocols: ['h2'].
      // http://dartbug.com/37950
      return await SecureSocket.secure(
        _tmpSocket,
        host: credentials.authority ?? _host,
        context: credentials.securityContext,
        onBadCertificate: (cert) {
          if (credentials.onBadCertificate != null) {
            return credentials.onBadCertificate!(
              cert,
              credentials.authority ?? _host,
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
  Future<void> connect({String? host, int? port}) async {
    _host = host ?? _host;
    _port = port ?? _port;
    if (status != ConnectStatus.disconnect) {
      return Future.value();
    }
    status = ConnectStatus.connecting;
    try {
      _socket = await getConnectionSocket();
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
      status = ConnectStatus.disconnect;
      _onError?.call(Error.from(e));
      _onClose?.call();
      return Future.value();
    }
    _broadcastNotifications();
    return Future.value();
  }

  /// internal function
  Future<StreamSubscription<Uint8List>> _broadcastNotifications() async {
    var _sub = _socket?.listen((streamData) {
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
    }, onDone: () {
      status = ConnectStatus.disconnect;
      _onClose?.call();
    }, onError: (e) {
      status = ConnectStatus.disconnect;
      _onError?.call(Error.from(e));
      _onClose?.call();
    }, cancelOnError: true);
    return Future.value(_sub);
  }
}
