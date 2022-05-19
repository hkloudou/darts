## Quickstart Guide

### tcp
``` dart
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
```

<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
<!-- 
TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
 -->

## Reconnection attributes
Besides the error and advisory callbacks mentioned above you can also set a few reconnection attributes in the connection options:
- allowReconnect `bool`
> allowReconnect enables reconnection logic to be used when we encounter a disconnect from the current server. Default is `false`
- reconnectWait `Duration`
> reconnectWait sets the time to backoff after attempting to (and failing to) reconnect. Default `const Duration(seconds: 2)`
- customReconnectDelayCB `Duration Function()?`
> customReconnectDelayCB is invoked after the library tried every URL in the server list and failed to reconnect. It passes to the user the current number of attempts. This function returns the amount of time the library will sleep before attempting to reconnect again. It is strongly recommended that this value contains some jitter to prevent all connections to attempt reconnecting at the same time.