import 'package:dart_mqtt/dart_mqtt.dart';

void main() async {
  var transport = XTransportTcpClient.from(
    "broker.emqx.io",
    1883,
    log: true,
  );
  var cli = MqttClient(
    transport,
    log: true,
  )
    ..withKeepalive(10)
    ..withClientID("mqttx_test");
  cli.onMqttConack((msg) {
    print("onMqttConack: $msg");
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

  await cli.subscribe(
    "test/topic",
    onMessage: (msg) {
      print(msg);
    },
    futureWaitData: true,
  );
}
