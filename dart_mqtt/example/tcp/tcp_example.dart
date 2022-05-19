import 'package:dart_mqtt/dart_mqtt.dart';

void main() async {
  var cli = MqttClient("broker.emqx.io", 1883, log: true, allowReconnect: true)
    ..withKeepalive(20)
    ..withClientID("mqtt_test");
  cli.onMqttConack((msg) {
    if (msg.returnCode != MqttConnectReturnCode.connectionAccepted) {
      // cli.
      cli.close();
      return;
    }
    cli.subscribe("test111", onMessage: (msg) {});
  });
  cli.onBeforeReconnect(() async {
    print("reconnecting...");
  });

  cli.start();
}
