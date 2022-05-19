import 'dart:io';
import 'dart:typed_data';

import 'package:xtransport/xtransport.dart';

class WtEx2 implements ITransportPacket {
  @override
  Uint8List pack() {
    return Uint8List.fromList([1, 2, 3, 4, 5]);
  }
}

void main(List<String> arguments) async {
  var cli = XTransportTcpClient.from(
    "127.0.0.1",
    8883,
    credentials: XtransportCredentials.secure(
      authority: "xx.apple.com",
      certificates: File('cert/ca.pem').readAsBytesSync(),
      clientCertificateBytes: File('cert/client.pem').readAsBytesSync(),
      clientPrivateKeyBytes: File('cert/client.key').readAsBytesSync(),
      onBadCertificate: (_x509, _host) => true,
    ),
  );
  cli.onMessage((msg) {
    print(msg.toJson());
    // throw ("haha");
    cli.close();
  });

  cli.onClose(() {
    print("closed");
    // cli.credentials.authority="";
    // cli.credentials = XtransportCredentials.insecure();
    // Future.delayed(const Duration(seconds: 1)).then((_) => cli.connect());
    // cli.connect();
  });
  cli.onError((err) {
    print("Error! ${err.errMsg}");
  });
  cli.onConnect(() {
    print("connected");
    cli.send(WtEx2());
  });
  cli.connect();
  await Future.delayed(const Duration(seconds: 10));
}
