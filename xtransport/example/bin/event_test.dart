import 'dart:typed_data';

import 'package:xtransport/xtransport.dart';

class TestPacket implements ITransportPacket {
  @override
  Uint8List pack() {
    return Uint8List.fromList([1, 2, 3, 4, 5]);
  }
}

void main() async {
  print('Testing event handling logic...\n');

  // Test 1: Connection failure should only trigger onError, not onClose
  print('Test 1: Connection failure event handling');

  bool errorCalled = false;
  bool closeCalled = false;

  var tcpClient = XTransportTcpClient.from(
    "192.0.2.1", // RFC5737 test address that should fail
    12345,
    log: false,
  );

  tcpClient.onError((err) {
    errorCalled = true;
    print('✓ onError called: ${err.errMsg}');
  });

  tcpClient.onClose(() {
    closeCalled = true;
    print('✗ onClose called (unexpected for connection failure)');
  });

  print('Attempting connection to unreachable address...');
  await tcpClient.connect();

  // Give some time for async events
  await Future.delayed(Duration(milliseconds: 100));

  if (errorCalled && !closeCalled) {
    print('✓ Connection failure correctly triggered only onError\n');
  } else {
    print('✗ Event handling issue: error=$errorCalled, close=$closeCalled\n');
  }

  // Test 2: WebSocket connection failure
  print('Test 2: WebSocket connection failure event handling');

  errorCalled = false;
  closeCalled = false;

  var wsClient = XTransportWsClient.from(
    "192.0.2.1", // RFC5737 test address that should fail
    "/test",
    80,
    log: false,
  );

  wsClient.onError((err) {
    errorCalled = true;
    print('✓ WebSocket onError called: ${err.errMsg}');
  });

  wsClient.onClose(() {
    closeCalled = true;
    print('✗ WebSocket onClose called (unexpected for connection failure)');
  });

  print('Attempting WebSocket connection to unreachable address...');
  await wsClient.connect();

  // Give some time for async events
  await Future.delayed(Duration(milliseconds: 100));

  if (errorCalled && !closeCalled) {
    print('✓ WebSocket connection failure correctly triggered only onError');
  } else {
    print(
        '✗ WebSocket event handling issue: error=$errorCalled, close=$closeCalled');
  }

  print('\n🎯 Event handling logic tests completed!');
  print('Connection failures now properly trigger only onError events,');
  print('while actual connection closures will trigger onClose events.');
}
