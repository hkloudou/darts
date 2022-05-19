import 'dart:io';

import 'package:dart_mqtt/dart_mqtt.dart';

void main() async {
  var cli = MqttClient(
    "127.0.0.1",
    8883,
    credentials: XtransportCredentials.secure(
      authority: "fake.apple.com",
      certificates: File('cert/ca.pem').readAsBytesSync(),
      clientCertificateBytes: File('cert/client.pem').readAsBytesSync(),
      clientPrivateKeyBytes: File('cert/client.key').readAsBytesSync(),
      onBadCertificate: (_x509, _host) => true,
    ),
    log: true,
  )
    ..withKeepalive(0)
    ..withClientID("mqttx_test");
  cli.onMqttConack((msg) {
    if (msg.returnCode != MqttConnectReturnCode.connectionAccepted) {
      cli.close();
      return;
    }
    cli.reSub();
  });

  cli.onBeforeReconnect(() async {
    print("reconnecting...");
  });
  cli.start();
  cli.subscribe("test/topic", onMessage: (msg) {
    print(msg);
  }).then((_) {
    print("subed1");
  });
  cli.subscribe("test/t2", onMessage: (msg) {
    print(msg);
    print("xx");
  }).then((_) {
    print("subed2");
  });
}
