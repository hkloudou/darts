import 'dart:typed_data';

import 'package:xtransport/src/jsons.dart';
import 'package:xtransport/src/shared/credentials.dart';

// import 'dart:ui';

class Error {
  String errMsg = "";
  Error.from(dynamic msg) {
    errMsg = msg.toString();
  }
  Error.fromString(String msg) {
    errMsg = msg;
  }
}

abstract class ITransportPacket {
  Uint8List pack();
}

// ITransportClient
abstract class ITransportClient {
  // ChannelCredentials credentials confis
  XtransportCredentials credentials = const XtransportCredentials.insecure();

  /// connectStatus [disconnect, connecting, connected, paused]
  ConnectStatus status = ConnectStatus.disconnect;

  /*
    Function
  */
  /// send a Packet to connection ioSink
  void send(ITransportPacket obj);

  /// close the socket
  void close();

  /// onClose Event Handler
  void onClose(void Function() fn);

  /// onClose Event Handler
  void onConnect(void Function() fn);

  /// onError Event Handler
  void onError(void Function(Error err) fn);

  /// onMessage Event Handler
  void onMessage(void Function(Message msg) fn);

  /// connect to the server
  Future<void> connect({String? host, int? port});
}

enum ConnectStatus { disconnect, connecting, connected, paused }
