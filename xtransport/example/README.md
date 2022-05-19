## A simple command-line application.

## sample
``` dart
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
    1883,
  );
  cli.onMessage((msg) {
    print(msg.toJson());
    // throw ("haha");
    cli.close();
  });

  cli.onClose(() {
    print("closed");
    // Future.delayed(const Duration(seconds: 1)).then((_) => cli.connect());
    // cli.connect();
  });
  cli.onError((err) {
    print("Error! ${err.errMsg}");
  });
  cli.onConnect(() {
    print("connected");
    print("ready");
    cli.send(WtEx2());
  });

  cli.connect();
  cli.connect();
  await Future.delayed(const Duration(seconds: 10));
}

```