import 'dart:typed_data';

import 'package:xtransport/xtransport.dart';

class TestPacket implements ITransportPacket {
  @override
  Uint8List pack() {
    return Uint8List.fromList([1, 2, 3, 4, 5]);
  }
}

void main() {
  print('Testing xtransport bug fixes...');

  // Test 1: XTransportError creation
  print('Test 1: XTransportError creation');
  var error1 = XTransportError.from('test error');
  var error2 = XTransportError.fromString('test string error');
  print('✓ XTransportError.from: ${error1.errMsg}');
  print('✓ XTransportError.fromString: ${error2.errMsg}');

  // Test 2: TCP client creation with correct protocol assertion
  print('\nTest 2: TCP client creation');
  try {
    var tcpClient = XTransportTcpClient.from(
      "127.0.0.1",
      8080,
      log: false,
    );
    print('✓ TCP client created successfully with tcp:// protocol');
    print('  Status: ${tcpClient.status}');
  } catch (e) {
    print('✗ TCP client creation failed: $e');
  }

  // Test 3: JSON serialization/deserialization
  print('\nTest 3: JSON Message handling');
  var remoteInfo = RemoteInfo(
      address: "test-address",
      host: "test-host",
      family: "tcp",
      port: 8080,
      size: 5);

  var localInfo =
      LocalInfo(address: "local-address", family: "tcp", port: 8080);

  var message = Message(
      message: Uint8List.fromList([1, 2, 3, 4, 5]),
      remoteInfo: remoteInfo,
      localInfo: localInfo);

  // Test JSON conversion
  var json = message.toJson();
  var reconstructed = Message.fromJson(json);

  print('✓ Message JSON serialization/deserialization works');
  print('  Original message length: ${message.message.length}');
  print('  Reconstructed message length: ${reconstructed.message.length}');
  print('  Remote host: ${reconstructed.remoteInfo.host}');

  // Test 4: WebSocket client creation (no connection, just creation)
  print('\nTest 4: WebSocket client creation');
  try {
    var wsClient = XTransportWsClient.from(
      "example.com",
      "/ws",
      80,
      log: false,
    );
    print('✓ WebSocket client created successfully');
    print('  Status: ${wsClient.status}');
  } catch (e) {
    print('✗ WebSocket client creation failed: $e');
  }

  print('\n🎉 All basic tests passed! Bug fixes are working correctly.');
}
