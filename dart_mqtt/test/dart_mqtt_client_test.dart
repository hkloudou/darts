import 'dart:async';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:dart_mqtt/dart_mqtt.dart';
import 'package:dart_mqtt/src/mqtt.dart';
import 'package:xtransport/xtransport.dart';

/// An in-memory transport that plays the role of the broker, so the client's
/// connection lifecycle can be exercised without a network.
class FakeTransport extends ITransportClient {
  final sentPackets = <Uint8List>[];
  void Function()? _onConnectCb;
  void Function()? _onCloseCb;
  void Function(XTransportError err)? _onErrorCb;
  void Function(Message msg)? _onMessageCb;

  /// When false, connect() fails and fires only onError (mirrors
  /// xtransport >= 0.0.7 semantics for a failed connect attempt).
  bool reachable = true;
  int connectAttempts = 0;

  @override
  void send(ITransportPacket obj) {
    sentPackets.add(obj.pack());
  }

  @override
  void close() {
    if (status == ConnectStatus.disconnect) return;
    status = ConnectStatus.disconnect;
    _onCloseCb?.call();
  }

  /// Simulates the peer dropping the connection with a read error:
  /// xtransport fires onError followed by onClose for this case.
  void dropWithError() {
    status = ConnectStatus.disconnect;
    _onErrorCb?.call(XTransportError.fromString('reset by peer'));
    _onCloseCb?.call();
  }

  void deliver(List<int> bytes) {
    _onMessageCb?.call(Message(
      message: Uint8List.fromList(bytes),
      remoteInfo: RemoteInfo(),
      localInfo: LocalInfo(),
    ));
  }

  /// Delivers a CONNACK with return code 0 (accepted).
  void deliverConnack() => deliver([0x20, 0x02, 0x00, 0x00]);

  @override
  void onClose(void Function() fn) => _onCloseCb = fn;

  @override
  void onConnect(void Function() fn) => _onConnectCb = fn;

  @override
  void onError(void Function(XTransportError err) fn) => _onErrorCb = fn;

  @override
  void onMessage(void Function(Message msg) fn) => _onMessageCb = fn;

  @override
  Future<void> connect(
      {String? host, int? port, Duration? duration, Duration? deadline}) {
    connectAttempts++;
    if (!reachable) {
      status = ConnectStatus.disconnect;
      _onErrorCb?.call(XTransportError.fromString('connection refused'));
      return Future.value();
    }
    status = ConnectStatus.connected;
    _onConnectCb?.call();
    return Future.value();
  }
}

Future<void> pump([int ms = 20]) =>
    Future.delayed(Duration(milliseconds: ms));

void main() {
  group('MqttClient with fake transport', () {
    test('close()/pause() still sends DISCONNECT while connected', () async {
      final transport = FakeTransport();
      final client = MqttClient(transport)..withClientID('c1');
      client.start();
      await pump();
      transport.sentPackets.clear();

      client.pause();
      expect(
        transport.sentPackets.any((p) => p.isNotEmpty && p[0] == 0xE0),
        isTrue,
        reason: 'pause() must emit a DISCONNECT (0xE0) packet',
      );
    });

    test('QoS1 publish future completes when PUBACK arrives', () async {
      final transport = FakeTransport();
      final client = MqttClient(transport)..withClientID('c1');
      client.start();
      await pump();

      var acked = false;
      final fut = client
          .publish('a/b', qos: MqttQos.qos1, payload: Uint8List.fromList([1]))
          .then((_) => acked = true);
      await pump();
      expect(acked, isFalse, reason: 'no PUBACK yet');

      // msgid 1 is the first id the dispenser hands out after connect.
      transport.deliver([0x40, 0x02, 0x00, 0x01]);
      await fut.timeout(const Duration(seconds: 1));
      expect(acked, isTrue);
    });

    test('QoS1 publish future is released when the connection drops',
        () async {
      final transport = FakeTransport();
      final client = MqttClient(transport)..withClientID('c1');
      client.start();
      await pump();

      final fut = client.publish('a/b',
          qos: MqttQos.qos1, payload: Uint8List.fromList([1]));
      transport.dropWithError();
      await fut.timeout(const Duration(seconds: 1));
    });

    test('reconnect keeps retrying when a connect attempt fails', () async {
      final transport = FakeTransport();
      final client = MqttClient(
        transport,
        allowReconnect: true,
        reconnectWait: const Duration(milliseconds: 50),
      )..withClientID('c1');
      client.start();
      await pump();
      expect(transport.connectAttempts, 1);

      // Peer drops; the next connect attempts fail (only onError fires).
      transport.reachable = false;
      transport.dropWithError();
      await pump(400);
      expect(transport.connectAttempts, greaterThan(2),
          reason: 'failed reconnects must reschedule themselves');

      // Network comes back: the loop recovers.
      transport.reachable = true;
      await pump(200);
      expect(transport.status, ConnectStatus.connected);
      client.dispose();
      await pump(100);
    });

    test('a dropped connection reported via onError+onClose reconnects once',
        () async {
      final transport = FakeTransport();
      var closeEvents = 0;
      final client = MqttClient(
        transport,
        allowReconnect: true,
        reconnectWait: const Duration(milliseconds: 50),
      )..withClientID('c1');
      client.onClose(() async => closeEvents++);
      client.start();
      await pump();

      transport.dropWithError();
      await pump(150);
      expect(closeEvents, 1,
          reason: 'onError+onClose for one drop must notify only once');
      expect(transport.connectAttempts, 2,
          reason: 'one drop must schedule exactly one reconnect');
      client.dispose();
      await pump(100);
    });

    test('pending subscribe completes after reconnect + reSub + SUBACK',
        () async {
      final transport = FakeTransport();
      final client = MqttClient(
        transport,
        allowReconnect: true,
        reconnectWait: const Duration(milliseconds: 50),
      )..withClientID('c1');
      client.start();
      await pump();
      transport.deliverConnack();
      await pump();

      var subCompleted = false;
      final fut =
          client.subscribe('t/1').then((_) => subCompleted = true);
      await pump();
      expect(subCompleted, isFalse);

      // Connection drops before the SUBACK arrives.
      transport.dropWithError();
      await pump(150);
      // Reconnected: broker accepts and the client re-subscribes (msgid 1).
      transport.sentPackets.clear();
      transport.deliverConnack();
      await pump();
      expect(
        transport.sentPackets.any((p) => p.isNotEmpty && (p[0] >> 4) == 8),
        isTrue,
        reason: 'reSub must re-send SUBSCRIBE after reconnect',
      );
      transport.deliver([0x90, 0x03, 0x00, 0x01, 0x00]); // SUBACK msgid 1
      await fut.timeout(const Duration(seconds: 1));
      expect(subCompleted, isTrue);
      client.dispose();
      await pump(100);
    });

    test('subscribe timeout throws TimeoutException and cleans up', () async {
      final transport = FakeTransport();
      final client = MqttClient(transport)..withClientID('c1');
      client.start();
      await pump();
      transport.deliverConnack();
      await pump();

      await expectLater(
        client.subscribe('t/never',
            timeout: const Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('packets fragmented across data events are reassembled', () async {
      final transport = FakeTransport();
      final client = MqttClient(transport)..withClientID('c1');
      final received = <MqttMessagePublish>[];
      client.start();
      await pump();
      transport.deliverConnack();
      await pump();
      final sub = client.subscribe('a/b', onMessage: received.add);
      transport.deliver([0x90, 0x03, 0x00, 0x01, 0x00]); // SUBACK msgid 1
      await sub;

      // One PUBLISH split mid-header and mid-payload, then two PUBLISHes
      // coalesced into a single data event.
      final publish = [
        0x30, 0x0A, 0x00, 0x03, 0x61, 0x2F, 0x62, // topic "a/b"
        0x68, 0x65, 0x6C, 0x6C, 0x6F, // payload "hello"
      ];
      transport.deliver(publish.sublist(0, 1));
      transport.deliver(publish.sublist(1, 8));
      transport.deliver([...publish.sublist(8), ...publish, ...publish]);
      await pump();
      expect(received.length, 3);
      expect(String.fromCharCodes(received.first.data), 'hello');
    });

    test('a throwing onMessage callback does not stall later packets',
        () async {
      final transport = FakeTransport();
      final client = MqttClient(transport)..withClientID('c1');
      var calls = 0;
      client.start();
      await pump();
      transport.deliverConnack();
      await pump();
      final sub = client.subscribe('a/b', onMessage: (msg) {
        calls++;
        throw StateError('boom');
      });
      transport.deliver([0x90, 0x03, 0x00, 0x01, 0x00]); // SUBACK msgid 1
      await sub;

      final publish = [
        0x30, 0x0A, 0x00, 0x03, 0x61, 0x2F, 0x62,
        0x68, 0x65, 0x6C, 0x6C, 0x6F,
      ];
      transport.deliver([...publish, ...publish]);
      await pump();
      expect(calls, 2, reason: 'second packet must still be dispatched');
      expect(transport.status, ConnectStatus.connected,
          reason: 'a user-callback error must not close the connection');
    });
  });

  group('UTF-8 surrogate handling', () {
    test('well-formed surrogate pairs (emoji) are allowed', () {
      final buf = MqttBuffer();
      buf.writeUtf8String('chat/\u{1F600}');
      buf.rewind();
      expect(buf.readUtf8String(), 'chat/\u{1F600}');
    });

    test('unpaired high surrogate throws', () {
      final buf = MqttBuffer();
      expect(() => buf.writeUtf8String('bad\uD800'), throwsException);
    });

    test('unpaired low surrogate throws', () {
      final buf = MqttBuffer();
      expect(() => buf.writeUtf8String('bad\uDC00end'), throwsException);
    });
  });

  group('CONNACK reserved return codes', () {
    test('reserved code 6 is rejected as malformed', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.connack;
      header.remainingLength = 2;
      expect(
        () => MqttMessageConnack.fromByteBuffer(
            header, MqttBuffer.fromList([0x00, 0x06])),
        throwsException,
      );
    });
  });
}
