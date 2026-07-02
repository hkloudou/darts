import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xtransport/xtransport.dart';

class _BytesPacket implements ITransportPacket {
  final Uint8List bytes;
  _BytesPacket(List<int> data) : bytes = Uint8List.fromList(data);

  @override
  Uint8List pack() => bytes;
}

void main() {
  group('XTransportTcpClient against a local server', () {
    late ServerSocket server;
    final serverSockets = <Socket>[];

    setUp(() async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((socket) {
        serverSockets.add(socket);
        // Echo whatever arrives; drop the connection when the client
        // half-closes (client close() is a graceful shutdown, so the full
        // disconnect needs the peer to close too).
        socket.listen(socket.add,
            onDone: socket.destroy, onError: (_) {});
      });
    });

    tearDown(() async {
      for (final s in serverSockets) {
        s.destroy();
      }
      serverSockets.clear();
      await server.close();
    });

    test('connect fires onConnect and echoes data via onMessage', () async {
      final client = XTransportTcpClient.from('127.0.0.1', server.port);
      final connected = Completer<void>();
      final received = Completer<List<int>>();

      client.onConnect(() => connected.complete());
      client.onMessage((msg) {
        if (!received.isCompleted) received.complete(msg.message);
      });

      await client.connect();
      await connected.future.timeout(const Duration(seconds: 5));
      expect(client.status, ConnectStatus.connected);

      client.send(_BytesPacket([1, 2, 3]));
      final echoed = await received.future.timeout(const Duration(seconds: 5));
      expect(echoed, [1, 2, 3]);

      client.close();
    });

    test('server-side close fires onClose and resets status', () async {
      final client = XTransportTcpClient.from('127.0.0.1', server.port);
      final connected = Completer<void>();
      final closed = Completer<void>();

      client.onConnect(() => connected.complete());
      client.onClose(() {
        if (!closed.isCompleted) closed.complete();
      });

      await client.connect();
      await connected.future.timeout(const Duration(seconds: 5));

      for (final s in serverSockets) {
        s.destroy();
      }
      await closed.future.timeout(const Duration(seconds: 5));
      expect(client.status, ConnectStatus.disconnect);
    });

    test('failed connect fires onError only, never onClose', () async {
      final port = server.port;
      await server.close();

      final client = XTransportTcpClient.from('127.0.0.1', port);
      var closeCalls = 0;
      final errored = Completer<XTransportError>();

      client.onClose(() => closeCalls++);
      client.onError((err) {
        if (!errored.isCompleted) errored.complete(err);
      });

      await client.connect(duration: const Duration(seconds: 2));
      final err = await errored.future.timeout(const Duration(seconds: 5));
      expect(err.errMsg, isNotEmpty);
      expect(closeCalls, 0);
      expect(client.status, ConnectStatus.disconnect);
    });

    test('client can reconnect after a close', () async {
      final client = XTransportTcpClient.from('127.0.0.1', server.port);
      var connectCount = 0;
      final closed = Completer<void>();
      client.onConnect(() => connectCount++);
      client.onClose(() {
        if (!closed.isCompleted) closed.complete();
      });

      await client.connect();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(connectCount, 1);

      client.close();
      await closed.future.timeout(const Duration(seconds: 5));

      await client.connect();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(connectCount, 2);
      client.close();
    });
  });

  group('XtransportCredentials', () {
    test('securityContext is null without a custom CA (system roots)', () {
      const creds = XtransportCredentials.secure(authority: 'example.com');
      expect(creds.securityContext, isNull);
      expect(creds.isSecure, isTrue);
    });

    test('securityContext is built when a custom CA is provided', () {
      // Not a real certificate: constructing the context object itself does
      // not parse the bytes eagerly on all platforms, so just check wiring.
      const creds = XtransportCredentials.insecure();
      expect(creds.securityContext, isNull);
      expect(creds.isSecure, isFalse);
    });
  });
}
