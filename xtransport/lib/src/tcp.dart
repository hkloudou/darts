import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:xtransport/src/interface.dart';
import 'package:xtransport/src/jsons.dart';
import 'package:xtransport/src/shared/credentials.dart';
import 'dart:developer' as developer;

class XTransportTcpClient implements ITransportClient {
  /*
    interface fields 
  */
  @override
  XtransportCredentials credentials = const XtransportCredentials.insecure();

  @override
  ConnectStatus status = ConnectStatus.disconnect;

  bool log = false;

  String _host;
  int _port;
  Socket? _socket;
  Duration? _deadline;
  Duration _duration = Duration(seconds: 20);

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
      developer.log(
        "send data",
        name: "error",
        error: e,
      );
      // _onError?.call(Error.from(e));
      close();
    }
  }

  @override
  void close() {
    _socket?.close();
    developer.log(
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
  void onError(void Function(Error err) fn) => _onError = fn;

  @override
  void onMessage(void Function(Message msg) fn) => _onMessage = fn;

  XTransportTcpClient.from(
    this._host,
    this._port, {
    this.log = false,
    this.credentials = const XtransportCredentials.insecure(),
  });

  Future<Socket> getConnectionSocket({Duration? duration}) async {
    var _tmpSocket = await Socket.connect(_host, _port,
        timeout: duration ?? const Duration(seconds: 60));
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
        // keyLog: (txt) {
        //   print("KL: $txt");
        // },
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
  Future<void> connect(
      {String? host, int? port, Duration? duration, Duration? deadline}) async {
    // print("xtransport tcp connect: $host");
    if (log) {
      developer.log(
        "\u001b[32m${"connecting"}\u001b[0m",
        time: DateTime.now(),
        name: "tcp",
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
      developer.log(
        "connect",
        error: e,
        name: "tcp",
      );
      status = ConnectStatus.disconnect;
      _onError?.call(Error.from(e));
      _onClose?.call();
      return Future.value();
    }
    _broadcastNotifications(deadline: _deadline);
    // .then((value) {
    //   // print("finish boast");
    // });
    return Future.value();
  }

  /// internal function
  Future<StreamSubscription<Uint8List>> _broadcastNotifications(
      {Duration? deadline}) async {
    // print("bd deadline: $deadline");
    Stream<Uint8List>? _sub = _socket;
    if (deadline != null) {
      _sub = _socket?.timeout(
        deadline * 1.5,
        onTimeout: (sink) {
          // print("onTimeOut");
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
        // print("xtransport.onDone");
        developer.log("onDone", name: "tcp");
        status = ConnectStatus.disconnect;
        _onClose?.call();
      },
      onError: (e) {
        // print("xtransport.onError");
        developer.log("onError", name: "tcp", error: e);
        status = ConnectStatus.disconnect;
        _onError?.call(Error.from(e));
        // _onClose?.call();
      },
      cancelOnError: true,
    );

    return Future.value(ret);
  }
}
