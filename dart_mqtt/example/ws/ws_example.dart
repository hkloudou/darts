import 'package:dart_mqtt/dart_mqtt.dart';

void main() async {
  var transport = XTransportWsClient.from(
    "broker.emqx.io",
    "/mqtt",
    8083,
    log: true,
    protocols: ["mqtt"], // important
  );
  var cli = MqttClient(transport, log: true, allowReconnect: true)
    ..withKeepalive(10)
    ..withClientID("mqttx_test");
  cli.onMqttConack((msg) {
    // print("onMqttConack: $msg");
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
    // print(msg);
  });
}
