## Quickstart Guide

### tcp
``` dart
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
```

## Reconnection attributes
Besides the error and advisory callbacks mentioned above you can also set a few reconnection attributes in the connection options:
- allowReconnect `bool`
> allowReconnect enables reconnection logic to be used when we encounter a disconnect from the current server. Default is `false`
- reconnectWait `Duration`
> reconnectWait sets the time to backoff after attempting to (and failing to) reconnect. Default `const Duration(seconds: 2)`
- customReconnectDelayCB `Duration Function()?`
> customReconnectDelayCB is invoked after the library tried every URL in the server list and failed to reconnect. It passes to the user the current number of attempts. This function returns the amount of time the library will sleep before attempting to reconnect again. It is strongly recommended that this value contains some jitter to prevent all connections to attempt reconnecting at the same time.