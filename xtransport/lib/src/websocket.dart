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
