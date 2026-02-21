import 'package:dart_mqtt/dart_mqtt.dart';

void main() async {
  var transport = XTransportTcpClient.from(
    "broker.emqx.io",
    8883,
    log: true,
    credentials: XtransportCredentials.secure(
      // authority: "fake.apple.com",
      // certificates: File('cert/ca.pem').readAsBytesSync(),
      // clientCertificateBytes: File('cert/client.pem').readAsBytesSync(),
      // clientPrivateKeyBytes: File('cert/client.key').readAsBytesSync(),
      onBadCertificate: (_x509, _host) {
        print("onBadCertificate x509.subject: ${_x509.subject}");
        print("onBadCertificate x509.issuer: ${_x509.issuer}");
        print("onBadCertificate x509.pem: ${_x509.pem}");
        print("onBadCertificate host: $_host");
        return true;
      },
    ),
  );
  var cli = MqttClient(transport, log: true, allowReconnect: true)
    ..withKeepalive(10)
    ..withClientID("mqttx_test");
  cli.onMqttConack((msg) {
    if (msg.returnCode != MqttConnectReturnCode.connectionAccepted) {
      cli.close();
    }
  });

  cli.onBeforeReconnect(() async {
    print("reconnecting...");
  });
  cli.start();
  cli.subscribe("test/topic", onMessage: (msg) {
    print(msg);
  });
}
