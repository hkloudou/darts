import 'dart:async';
import 'dart:io';

import 'package:xtransport/src/interface.dart';
import 'package:xtransport/src/jsons.dart';
import 'package:xtransport/src/shared/credentials.dart';
import 'dart:developer' as developer;

class XTransportWsClient implements ITransportClient {
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
  WebSocket? _socket;
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
      _socket?.add(obj.pack());
    } catch (e) {
      developer.log(
        "send data",
        name: "ws",
        error: e,
      );
      close();
    }
  }

  @override
  void close() {
    // _socket?.
    developer.log(
      "\u001b[31m${"closed"}\u001b[0m",
      time: DateTime.now(),
      name: "ws",
    );
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
    this._port, {
    this.log = false,
    this.credentials = const XtransportCredentials.insecure(),
  });

  Future<WebSocket> getConnectionSocket({Duration? duration}) async {
    HttpClient? customCient;
    if (credentials.isSecure) {
      customCient = HttpClient(context: credentials.securityContext);
      // customCient.

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
      developer.log(
        (credentials.isSecure ? "wss" : "ws") +
            "://" +
            _host +
            ":$_port" +
            "/mqtt",
        time: DateTime.now(),
        name: "ws",
      );
    }
    var _tmpSocket = await WebSocket.connect(
      (credentials.isSecure ? "wss" : "ws") +
          "://" +
          (credentials.authority ?? _host) +
          ":$_port" +
          "/mqtt",
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
      developer.log(
        "\u001b[32m${"connecting"}\u001b[0m",
        time: DateTime.now(),
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
        // address: _socket?.remoteAddress.address ?? "",
        // host: (credentials.isSecure ? credentials.authority : null) ??
        //     _socket?.remoteAddress.host ??
        //     "",
        port: _port,
        // family: _socket?.remoteAddress.type.name ?? "",
      );
      _localInfo = LocalInfo(
        address: _localInfo.address,
        // family: _socket?.address.type.name ?? "",
        // port: _socket?.port ?? 0,
      );
      status = ConnectStatus.connected;
      _onConnect?.call();
    } catch (e) {
      developer.log(
        "connect",
        error: e,
        name: "ws",
      );
      status = ConnectStatus.disconnect;
      _onError?.call(Error.from(e));
      _onClose?.call();
      return Future.value();
    }
    _socket?.pingInterval = deadline;
    _broadcastNotifications();
    // .then((value) {
    //   // print("finish boast");
    // });
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
        // print("xtransport.onDone");
        developer.log("onDone", name: "ws");
        status = ConnectStatus.disconnect;
        _onClose?.call();
      },
      onError: (e) {
        // print("xtransport.onError");
        developer.log("onError", name: "ws", error: e);
        status = ConnectStatus.disconnect;
        _onError?.call(Error.from(e));
        // _onClose?.call();
      },
      cancelOnError: true,
    );

    return Future.value(ret);
  }
}


// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:xtransport/src/interface.dart';
// import 'package:http2/http2.dart';

// class WebsocketClient implements XTransportClient {
//   final String url;
//   Map<String, dynamic>? headers;
//   WebSocket? channel;
//   SecurityContext? securityContext;
//   Completer com = Completer();

//   // StreamController<T> streamController = StreamController.broadcast(sync: true);

//   WebsocketClient(this.url, {this.headers, this.securityContext});

//   void onData(dynamic data) {}
//   // WebsocketClient._internal() {
//   //   // initWebSocketConnection();
//   // }

//   Future<void> ready() async {
//     return com.future;
//   }

//   Future<WebSocket> connect() async {
//     // var uri = Uri.parse('https://www.google.com/');
// // WebSocket(url)
//     // var transport = new ClientTransportConnection.viaSocket(
//     //   await SecureSocket.connect(
//     //     uri.host,
//     //     uri.port,
//     //     supportedProtocols: ['h2'],
//     //   ),
//     // );
//     // HttpClient _httpClient = new HttpClient();
//     // _httpClient.
//     // _httpClient.addCredentials(url, realm, credentials)
//     // rootBundle.load(key)

//     // context.setAlpnProtocols(["TLS1.3"], false);

//     try {
//       late WebSocket ws;
// //       bool _certificateCheck(X509Certificate cert, String host, int port) =>
// //     host == 'local.domain.ext'; // <- change

// // HttpClient client = new HttpClient()
// //     ..badCertificateCallback = (_certificateCheck);

//       if (securityContext != null) {
//         HttpClient client = HttpClient(context: securityContext);
//         // securityContext.useCertificateChainBytes(chainBytes)
//         // X509Certificate.
//         // client.addCredentials(Uri.parse("wss://mongo-svc.ds:11444/ws"), "mongo-svc2", credentials)
//         // client.authenticate
//         client.badCertificateCallback = (cert, host, port) {
//           print(cert);
//           print(host);
//           print(port);
//           return true;
//         };
//         // client.
//         // client.addCredentials(url, realm, credentials);
//         // client.
//         // WebSocket.fromUpgradedSocket(socket)
//         ws = await WebSocket.connect(url,
//             headers: headers, customClient: client);
//         // SecureSocket.secure(ws);
//         // RawSecureSocket.connect()

//       } else {
//         ws = await WebSocket.connect(url, headers: headers);
//       }
//       // RawSocket.connect(host, port)
//       ws.pingInterval = const Duration(seconds: 5);
//       return ws;
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error! can not connect WS connectWs " + e.toString());
//       }
//       await Future.delayed(const Duration(milliseconds: 10000));
//       return await connect();
//     }
//   }

//   Future<void> connectxxx() async {
//     var ccc = HttpClient();
//     // WebsocketClient(url)
//     // SecureSocket.secure(ccc.)
//     // final securityContext = _options.credentials.securityContext;
//     var _socket = await Socket.connect("", 443);
//     // Don't wait for io buffers to fill up before sending requests.
//     if (_socket.address.type != InternetAddressType.unix) {
//       _socket.setOption(SocketOption.tcpNoDelay, true);
//     }
//     if (securityContext != null) {
//       // Todo(sigurdm): We want to pass supportedProtocols: ['h2'].
//       // http://dartbug.com/37950
//       _socket = await SecureSocket.secure(
//         _socket,
//         // This is not really the host, but the authority to verify the TLC
//         // connection against.
//         //
//         // We don't use `this.authority` here, as that includes the port.
//         host: "xx.apple.com",
//         context: securityContext,
//         onBadCertificate: (_) => true,
//       );
//     }

//     var x = ClientTransportConnection.viaSocket(_socket);
//     // x.makeRequest(headers).
//   }
// //   // connectWebsocket from websocket_impl.dart
// //   Future<WebSocket> connectWebsocket(
// //       String url, Iterable<String>? protocols, Map<String, dynamic>? headers,
// //       {CompressionOptions compression = CompressionOptions.compressionDefault,
// //       HttpClient? customClient}) async {
// //     Uri uri = Uri.parse(url);
// //     if (uri.scheme != "ws" && uri.scheme != "wss") {
// //       throw WebSocketException("Unsupported URL scheme '${uri.scheme}'");
// //     }
// //     Random random = Random();
// //     // Generate 16 random bytes.
// //     Uint8List nonceData = Uint8List(16);
// //     for (int i = 0; i < 16; i++) {
// //       nonceData[i] = random.nextInt(256);
// //     }
// //     String nonce = base64Encode(nonceData);

// //     final callerStackTrace = StackTrace.current;
// // // http
// //     uri = Uri(
// //         scheme: uri.scheme == "wss" ? "https" : "http",
// //         userInfo: uri.userInfo,
// //         host: uri.host,
// //         port: uri.port,
// //         path: uri.path,
// //         query: uri.query,
// //         fragment: uri.fragment);
// //     (customClient ?? HttpClient()).openUrl("GET", uri).then((request) {
// //       if (uri.userInfo != null && uri.userInfo.isNotEmpty) {
// //         // If the URL contains user information use that for basic
// //         // authorization.
// //         String auth = base64Encode(utf8.encode(uri.userInfo));
// //         request.headers.set(HttpHeaders.authorizationHeader, "Basic $auth");
// //       }
// //       if (headers != null) {
// //         headers.forEach((field, value) => request.headers.add(field, value));
// //       }
// //       // Setup the initial handshake.
// //       request.headers
// //         ..set(HttpHeaders.connectionHeader, "Upgrade")
// //         ..set(HttpHeaders.upgradeHeader, "websocket")
// //         ..set("Sec-WebSocket-Key", nonce)
// //         ..set("Cache-Control", "no-cache")
// //         ..set("Sec-WebSocket-Version", "13");
// //       if (protocols != null) {
// //         request.headers.add("Sec-WebSocket-Protocol", protocols.toList());
// //       }

// //       if (compression.enabled) {
// //         request.headers
// //             .add("Sec-WebSocket-Extensions", compression._createHeader());
// //       }

// //       return request.close();
// //     });
// //   }

//   void _onDisconnected() {
//     print("on Dis");
//     // initWebSocketConnection();
//   }

//   void initWebSocketConnection() async {
//     if (kDebugMode) {
//       print("conecting...");
//     }
//     channel = await connect();
//     if (kDebugMode) {
//       print("socket connection initializied");
//     }
//     if (!com.isCompleted) {
//       com.complete();
//     }
//     channel?.done.then((dynamic _) => _onDisconnected());
//     broadcastNotifications();
//   }

//   void broadcastNotifications() {
//     channel?.listen((streamData) {
//       print("data");
//       // streamController.add(streamData);
//     }, onDone: () {
//       // initWebSocketConnection();
//       print("onDone");
//     }, onError: (e) {
//       print("onError");
//       // initWebSocketConnection();
//     });
//   }

//   @override
//   void send(Packet obj) {
//     channel?.add(obj.pack().toList());
//     // channel?.ad
//   }

//   @override
//   void close() {
//     channel?.close();
//   }
// }

// class WebsocketTransport implements Transport {
//   @override
//   WebsocketClient dial(
//     String addr, {
//     Map<String, dynamic>? headers,
//     SecurityContext? securityContext,
//   }) {
//     // WebSocket.open
//     var x = WebsocketClient(
//       addr,
//       headers: headers,
//       securityContext: securityContext,
//     );
//     // var ws = WebSocket.connect(
//     //   addr,
//     //   headers: headers,
//     // );
//     // // Future.doWhile(() => null)
//     // ws.then((ww) {});
//     // print("object");
//     x.initWebSocketConnection();
//     return x;
//   }
// }
