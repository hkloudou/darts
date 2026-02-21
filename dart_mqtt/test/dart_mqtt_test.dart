import 'dart:async';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:dart_mqtt/dart_mqtt.dart';
import 'package:dart_mqtt/src/mqtt.dart';

void main() {
  // ============================================================
  // BUG-1: UNSUBACK readFrom() now called
  // ============================================================
  group('BUG-1: UNSUBACK parsing', () {
    test('fromByteBuffer correctly reads msgid', () {
      // UNSUBACK variable header: 2-byte message ID
      // msgid = 0x0042 = 66
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.unsuback;
      header.remainingLength = 2;

      final buf = MqttBuffer.fromList([0x00, 0x42]);
      final unsuback = MqttMessageUnSuback.fromByteBuffer(header, buf);
      expect(unsuback.msgid, equals(66));
    });

    test('fromByteBuffer reads different msgid values', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.unsuback;
      header.remainingLength = 2;

      final buf = MqttBuffer.fromList([0x01, 0x00]); // msgid = 256
      final unsuback = MqttMessageUnSuback.fromByteBuffer(header, buf);
      expect(unsuback.msgid, equals(256));
    });
  });

  // ============================================================
  // BUG-2: Remaining length decoding
  // ============================================================
  group('BUG-2: Remaining length decoding', () {
    test('1-byte remaining length (0)', () {
      // CONNACK: type=0x20, remaining=2, payload=[0x00, 0x00]
      final buf = MqttBuffer.fromList([0x20, 0x02, 0x00, 0x00]);
      final head = MqttFixedHead.readFrom(buf);
      expect(head.messageType, equals(MqttMessageType.connack));
      expect(head.remainingLength, equals(2));
      expect(buf.availableBytes, equals(2)); // 2 bytes left for payload
    });

    test('1-byte remaining length (127)', () {
      final buf = MqttBuffer();
      buf.addAll([0x30, 0x7F]); // PUBLISH, remaining=127
      // add 127 payload bytes
      buf.addAll(List.filled(127, 0));
      final head = MqttFixedHead.readFrom(buf);
      expect(head.remainingLength, equals(127));
    });

    test('2-byte remaining length (128)', () {
      // 128 = 0x00 with continuation + 0x01
      final buf = MqttBuffer.fromList([0x30, 0x80, 0x01]);
      final head = MqttFixedHead.readFrom(buf);
      expect(head.remainingLength, equals(128));
    });

    test('4-byte remaining length (max: 268435455)', () {
      // 268435455 = 0xFF, 0xFF, 0xFF, 0x7F
      final buf = MqttBuffer.fromList([0x30, 0xFF, 0xFF, 0xFF, 0x7F]);
      final head = MqttFixedHead.readFrom(buf);
      expect(head.remainingLength, equals(268435455));
    });

    test(
        'malformed: all 4 bytes have continuation bit → throws without consuming 5th byte',
        () {
      // 4 bytes all with continuation bit set, plus a 5th byte (0xAA) that should NOT be consumed
      final buf = MqttBuffer.fromList([0x30, 0x80, 0x80, 0x80, 0x80, 0xAA]);
      expect(
        () => MqttFixedHead.readFrom(buf),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('exceeds 4 bytes'),
        )),
      );
      // The 5th byte (0xAA) should NOT have been consumed
      // header byte (1) + 4 remaining length bytes = 5 consumed
      // buf started with 6 bytes, so availableBytes should be 1
      expect(buf.availableBytes, equals(1));
    });

    test('empty buffer throws on remaining length read', () {
      final buf = MqttBuffer.fromList([0x30]); // only header byte, no length
      expect(
        () => MqttFixedHead.readFrom(buf),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Unexpected end of buffer'),
        )),
      );
    });
  });

  // ============================================================
  // BUG-3: Publish QoS > 0 serialization with msgid
  // ============================================================
  group('BUG-3: Publish message serialization', () {
    test('QoS 0 publish does not include message ID', () {
      final msg = MqttMessagePublish();
      msg.fixedHead.qos = MqttQos.qos0;
      msg.toTopic('test/topic');
      msg.data = Uint8List.fromList([1, 2, 3]);

      final packed = msg.pack();
      // Parse it back
      final buf = MqttBuffer.fromList(packed);
      final head = MqttFixedHead.readFrom(buf);
      expect(head.qos, equals(MqttQos.qos0));

      final parsed = MqttMessagePublish.fromByteBuffer(
          head, MqttBuffer.fromList(buf.read(head.remainingLength)));
      expect(parsed.topicName, equals('test/topic'));
      expect(parsed.msgid, equals(0)); // QoS 0 has no msgid
      expect(parsed.data, equals([1, 2, 3]));
    });

    test('QoS 1 publish includes message ID in serialization', () {
      final msg = MqttMessagePublish();
      msg.fixedHead.qos = MqttQos.qos1;
      msg.msgid = 42;
      msg.toTopic('test/topic');
      msg.data = Uint8List.fromList([1, 2, 3]);

      final packed = msg.pack();
      final buf = MqttBuffer.fromList(packed);
      final head = MqttFixedHead.readFrom(buf);
      expect(head.qos, equals(MqttQos.qos1));

      final parsed = MqttMessagePublish.fromByteBuffer(
          head, MqttBuffer.fromList(buf.read(head.remainingLength)));
      expect(parsed.topicName, equals('test/topic'));
      expect(parsed.msgid, equals(42));
      expect(parsed.data, equals([1, 2, 3]));
    });
  });

  // ============================================================
  // BUG-4: CONNACK unknown return code
  // ============================================================
  group('BUG-4: CONNACK return code', () {
    test('valid return code 0 (connectionAccepted)', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.connack;
      header.remainingLength = 2;

      final buf = MqttBuffer.fromList([0x00, 0x00]); // flags=0, ret=0
      final connack = MqttMessageConnack.fromByteBuffer(header, buf);
      expect(
          connack.returnCode, equals(MqttConnectReturnCode.connectionAccepted));
    });

    test('valid return code 4 (badUsernameOrPassword)', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.connack;
      header.remainingLength = 2;

      final buf = MqttBuffer.fromList([0x00, 0x04]);
      final connack = MqttMessageConnack.fromByteBuffer(header, buf);
      expect(connack.returnCode,
          equals(MqttConnectReturnCode.badUsernameOrPassword));
    });

    test('unknown return code throws descriptive exception', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.connack;
      header.remainingLength = 2;

      final buf = MqttBuffer.fromList([0x00, 0xFF]); // ret=255, out of range
      expect(
        () => MqttMessageConnack.fromByteBuffer(header, buf),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Unknown CONNACK return code: 0xff'),
        )),
      );
    });

    test('return code 9 (just beyond enum range) throws', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.connack;
      header.remainingLength = 2;

      final buf = MqttBuffer.fromList([0x00, 0x09]);
      expect(
        () => MqttMessageConnack.fromByteBuffer(header, buf),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ============================================================
  // BUG-5: MessageIdentifierDispenser per-client
  // ============================================================
  group('BUG-5: MessageIdentifierDispenser independence', () {
    test('two dispensers have independent state', () {
      final d1 = MessageIdentifierDispenser();
      final d2 = MessageIdentifierDispenser();

      final id1a = d1.getNextMessageIdentifier();
      final id1b = d1.getNextMessageIdentifier();
      final id2a = d2.getNextMessageIdentifier();

      expect(id1a, equals(1));
      expect(id1b, equals(2));
      expect(id2a, equals(1)); // d2 starts from its own counter
    });

    test('reset on one dispenser does not affect another', () {
      final d1 = MessageIdentifierDispenser();
      final d2 = MessageIdentifierDispenser();

      d1.getNextMessageIdentifier(); // 1
      d1.getNextMessageIdentifier(); // 2
      d2.getNextMessageIdentifier(); // 1
      d2.getNextMessageIdentifier(); // 2
      d2.getNextMessageIdentifier(); // 3

      d1.reset();
      expect(d1.getNextMessageIdentifier(), equals(1));
      expect(d2.getNextMessageIdentifier(), equals(4)); // unaffected
    });

    test('wraps around at maxMessageIdentifier', () {
      final d = MessageIdentifierDispenser();
      // Manually set _mid close to max via repeated calls
      for (var i = 0; i < 32766; i++) {
        d.getNextMessageIdentifier();
      }
      expect(d.getNextMessageIdentifier(), equals(32767));
      expect(d.getNextMessageIdentifier(), equals(1)); // wraps
    });
  });

  // ============================================================
  // BUG-9: SUBACK multi return code
  // ============================================================
  group('BUG-9: SUBACK return codes', () {
    test('single topic return code', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.suback;
      header.remainingLength = 3; // 2 bytes msgid + 1 byte return code

      final buf = MqttBuffer.fromList([0x00, 0x01, 0x00]); // msgid=1, qos0
      final suback = MqttMessageSuback.fromByteBuffer(header, buf);
      expect(suback.msgid, equals(1));
      expect(suback.returnCodes, equals([0]));
    });

    test('multiple topic return codes', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.suback;
      header.remainingLength = 5; // 2 bytes msgid + 3 bytes return codes

      final buf = MqttBuffer.fromList([0x00, 0x0A, 0x00, 0x01, 0x02]);
      // msgid=10, returnCodes=[0(qos0), 1(qos1), 2(qos2)]
      final suback = MqttMessageSuback.fromByteBuffer(header, buf);
      expect(suback.msgid, equals(10));
      expect(suback.returnCodes, equals([0, 1, 2]));
      expect(suback.returnCodes.length, equals(3));
    });

    test('failure return code 0x80', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.suback;
      header.remainingLength = 3;

      final buf = MqttBuffer.fromList([0x00, 0x01, 0x80]); // failure
      final suback = MqttMessageSuback.fromByteBuffer(header, buf);
      expect(suback.returnCodes, equals([0x80]));
    });
  });

  // ============================================================
  // BUG-10+11: UTF-8 validation boundaries
  // ============================================================
  group('BUG-10+11: UTF-8 validation', () {
    test('null character U+0000 throws', () {
      final buf = MqttBuffer();
      expect(() => buf.writeUtf8String('hello\x00world'), throwsException);
    });

    test('control character U+0001 throws', () {
      final buf = MqttBuffer();
      expect(() => buf.writeUtf8String('hello\x01world'), throwsException);
    });

    test('control character U+001F throws', () {
      final buf = MqttBuffer();
      expect(() => buf.writeUtf8String('hello\x1Fworld'), throwsException);
    });

    test('space U+0020 is allowed', () {
      final buf = MqttBuffer();
      buf.writeUtf8String('hello world'); // U+0020 space should be fine
      expect(buf.length, greaterThan(0));
    });

    test('DEL U+007F throws', () {
      final buf = MqttBuffer();
      expect(() => buf.writeUtf8String('hello\x7Fworld'), throwsException);
    });

    test('C1 control U+009F throws', () {
      final buf = MqttBuffer();
      expect(
        () => buf.writeUtf8String('hello\u009Fworld'),
        throwsException,
      );
    });

    test('U+00A0 (non-breaking space) is allowed', () {
      final buf = MqttBuffer();
      buf.writeUtf8String('hello\u00A0world');
      expect(buf.length, greaterThan(0));
    });

    test('normal ASCII string is valid', () {
      final buf = MqttBuffer();
      buf.writeUtf8String('test/topic/123');
      expect(buf.length, greaterThan(0));
    });

    test('Unicode string (CJK) is valid', () {
      final buf = MqttBuffer();
      buf.writeUtf8String('\u00C0\u00E9\u00F1'); // non-ASCII Latin chars
      expect(buf.length, greaterThan(0));
    });
  });

  // ============================================================
  // BUG-15: UTF-8 string 65535 byte limit
  // ============================================================
  group('BUG-15: UTF-8 string length limit', () {
    test('string at 65535 bytes is allowed', () {
      final buf = MqttBuffer();
      final s = 'a' * 65535; // exactly 65535 bytes in UTF-8
      buf.writeUtf8String(s);
      expect(buf.length, equals(65535 + 2)); // +2 for length prefix
    });

    test('string over 65535 bytes throws', () {
      final buf = MqttBuffer();
      final s = 'a' * 65536;
      expect(
        () => buf.writeUtf8String(s),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('exceeds maximum length of 65535 bytes'),
        )),
      );
    });
  });

  // ============================================================
  // MqttBuffer: read/write round-trip
  // ============================================================
  group('MqttBuffer round-trip', () {
    test('readBits / writeBits', () {
      final buf = MqttBuffer();
      buf.writeBits(0x42);
      buf.writeBits(0xFF);
      expect(buf.readBits(), equals(0x42));
      expect(buf.readBits(), equals(0xFF));
    });

    test('readInteger / writeInteger', () {
      final buf = MqttBuffer();
      buf.writeInteger(0);
      buf.writeInteger(1);
      buf.writeInteger(256);
      buf.writeInteger(65535);
      expect(buf.readInteger(), equals(0));
      expect(buf.readInteger(), equals(1));
      expect(buf.readInteger(), equals(256));
      expect(buf.readInteger(), equals(65535));
    });

    test('readUtf8String / writeUtf8String', () {
      final buf = MqttBuffer();
      buf.writeUtf8String('hello');
      buf.writeUtf8String('mqtt/topic');
      buf.writeUtf8String('');
      expect(buf.readUtf8String(), equals('hello'));
      expect(buf.readUtf8String(), equals('mqtt/topic'));
      expect(buf.readUtf8String(), equals(''));
    });

    test('shrink removes consumed bytes', () {
      final buf = MqttBuffer();
      buf.addAll([1, 2, 3, 4, 5]);
      buf.readBits(); // reads 1
      buf.readBits(); // reads 2
      expect(buf.availableBytes, equals(3));
      buf.shrink();
      expect(buf.length, equals(3));
      expect(buf.availableBytes, equals(3));
      expect(buf.readBits(), equals(3));
    });

    test('read beyond buffer throws', () {
      final buf = MqttBuffer.fromList([0x01]);
      buf.readBits(); // consume it
      expect(() => buf.readBits(), throwsException);
    });
  });

  // ============================================================
  // Fixed header bit fields
  // ============================================================
  group('MqttFixedHead bit fields', () {
    test('messageType round-trip', () {
      for (final type in MqttMessageType.values) {
        final head = MqttFixedHead();
        head.messageType = type;
        expect(head.messageType, equals(type));
      }
    });

    test('qos round-trip', () {
      for (final qos in MqttQos.values) {
        final head = MqttFixedHead();
        head.messageType = MqttMessageType.publish;
        head.qos = qos;
        expect(head.qos, equals(qos));
      }
    });

    test('dup flag round-trip', () {
      final head = MqttFixedHead();
      head.messageType = MqttMessageType.publish;
      head.dup = true;
      expect(head.dup, isTrue);
      head.dup = false;
      expect(head.dup, isFalse);
    });

    test('retain flag round-trip', () {
      final head = MqttFixedHead();
      head.messageType = MqttMessageType.publish;
      head.retain = true;
      expect(head.retain, isTrue);
      head.retain = false;
      expect(head.retain, isFalse);
    });

    test('setting one field does not affect others', () {
      final head = MqttFixedHead();
      head.messageType = MqttMessageType.publish;
      head.qos = MqttQos.qos1;
      head.dup = true;
      head.retain = true;

      expect(head.messageType, equals(MqttMessageType.publish));
      expect(head.qos, equals(MqttQos.qos1));
      expect(head.dup, isTrue);
      expect(head.retain, isTrue);

      // Change one field
      head.qos = MqttQos.qos0;
      expect(head.messageType, equals(MqttMessageType.publish));
      expect(head.dup, isTrue);
      expect(head.retain, isTrue);
    });

    test('remaining length encoding round-trip', () {
      final testValues = [
        0,
        1,
        127,
        128,
        16383,
        16384,
        2097151,
        2097152,
        268435455
      ];
      for (final value in testValues) {
        final head = MqttFixedHead();
        head.messageType = MqttMessageType.publish;
        head.remainingLength = value;
        final bytes = head.headerBytes();

        // Parse it back
        final buf = MqttBuffer.fromList(bytes);
        final parsed = MqttFixedHead.readFrom(buf);
        expect(parsed.remainingLength, equals(value),
            reason: 'Failed for remainingLength=$value');
      }
    });
  });

  // ============================================================
  // CONNECT message serialization
  // ============================================================
  group('CONNECT message', () {
    test('basic connect packet serialization', () {
      final msg = MqttMessageConnect();
      msg.withClientID('test_client');
      msg.withKeepalive(60);

      final packed = msg.pack();
      expect(packed.length, greaterThan(0));

      // Verify header
      expect(packed[0] >> 4, equals(MqttMessageType.connect.index));
    });

    test('connect with auth', () {
      final msg = MqttMessageConnect();
      msg.withClientID('test');
      msg.withAuth('user', 'pass');

      final packed = msg.pack();
      expect(packed.length, greaterThan(0));
    });

    test('connect with clean session', () {
      final msg = MqttMessageConnect();
      msg.cleanStart = true;
      msg.withClientID('test');

      final packed = msg.pack();
      // The connect flags byte is at a fixed offset after the protocol name
      // Protocol: 0x00 0x04 "MQTT" 0x04 (7 bytes of variable header before flags)
      // Header: 1 byte type + remaining length bytes
      // Variable header starts after fixed header
      expect(packed.length, greaterThan(0));
    });
  });

  // ============================================================
  // SUBSCRIBE message serialization
  // ============================================================
  group('SUBSCRIBE message', () {
    test('single topic serialize/parse', () {
      final msg = MqttMessageSubscribe.withTopic(1, 'test/topic', MqttQos.qos0);
      final packed = msg.pack();
      expect(packed.length, greaterThan(0));
      // First byte should be SUBSCRIBE type with QoS 1 flag
      expect(packed[0] >> 4, equals(MqttMessageType.subscribe.index));
      expect((packed[0] & 0x06) >> 1, equals(MqttQos.qos1.index));
    });
  });

  // ============================================================
  // UNSUBSCRIBE message serialization
  // ============================================================
  group('UNSUBSCRIBE message', () {
    test('serialize', () {
      final msg = MqttMessageUnSubscribe.withTopic(['test/topic']);
      msg.withMessageID(5);
      final packed = msg.pack();
      expect(packed.length, greaterThan(0));
      expect(packed[0] >> 4, equals(MqttMessageType.unsubscribe.index));
    });
  });

  // ============================================================
  // DISCONNECT message
  // ============================================================
  group('DISCONNECT message', () {
    test('disconnect packet is correct', () {
      final msg = MqttMessageDisconnect();
      final packed = msg.pack();
      // DISCONNECT: type=14 (0xE0), remaining length=0
      expect(packed[0], equals(0xE0));
      expect(packed[1], equals(0x00));
      expect(packed.length, equals(2));
    });
  });

  // ============================================================
  // PINGREQ message
  // ============================================================
  group('PINGREQ message', () {
    test('pingreq packet is correct', () {
      final msg = MqttMessagePingreq();
      final packed = msg.pack();
      // PINGREQ: type=12 (0xC0), remaining length=0
      expect(packed[0], equals(0xC0));
      expect(packed[1], equals(0x00));
      expect(packed.length, equals(2));
    });
  });

  // ============================================================
  // MqttMessageFactory
  // ============================================================
  group('MqttMessageFactory', () {
    test('readHead from CONNACK bytes', () {
      final buf = MqttBuffer.fromList([0x20, 0x02]); // CONNACK, len=2
      final head = MqttMessageFactory.readHead(buf);
      expect(head.messageType, equals(MqttMessageType.connack));
      expect(head.remainingLength, equals(2));
    });

    test('readMessage CONNACK', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.connack;
      header.remainingLength = 2;

      final payload = MqttBuffer.fromList([0x00, 0x00]); // accepted
      final msg = MqttMessageFactory.readMessage(header, payload);
      expect(msg, isA<MqttMessageConnack>());
      expect((msg as MqttMessageConnack).returnCode,
          equals(MqttConnectReturnCode.connectionAccepted));
    });

    test('readMessage PUBLISH QoS 0', () {
      // Build a publish packet payload manually
      final payload = MqttBuffer();
      payload.writeUtf8String('test'); // topic
      payload.addAll([0x41, 0x42]); // data: "AB"

      final header = MqttFixedHead();
      header.messageType = MqttMessageType.publish;
      header.qos = MqttQos.qos0;
      header.remainingLength = payload.length;

      final msg = MqttMessageFactory.readMessage(
          header, MqttBuffer.fromList(payload.bytes));
      expect(msg, isA<MqttMessagePublish>());
      final pub = msg as MqttMessagePublish;
      expect(pub.topicName, equals('test'));
      expect(pub.data, equals([0x41, 0x42]));
    });

    test('readMessage PUBACK', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.puback;
      header.remainingLength = 2;

      final payload = MqttBuffer.fromList([0x00, 0x2A]); // msgid=42
      final msg = MqttMessageFactory.readMessage(header, payload);
      expect(msg, isA<MqttMessagePuback>());
      expect((msg as MqttMessagePuback).msgid, equals(42));
    });

    test('unsupported message type throws with descriptive message', () {
      final header = MqttFixedHead();
      header.messageType = MqttMessageType.pubrec;
      header.remainingLength = 0;

      final payload = MqttBuffer();
      expect(
        () => MqttMessageFactory.readMessage(header, payload),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('pubrec'),
        )),
      );
    });
  });

  // ============================================================
  // BUG-16: Topic matching (tested via extracted logic)
  // ============================================================
  group('BUG-16: Topic matching', () {
    // Replicate the _topicMatch logic for testing
    bool topicMatch(String filter, String topic) {
      if (filter == topic) return true;
      final filterParts = filter.split('/');
      final topicParts = topic.split('/');
      for (var i = 0; i < filterParts.length; i++) {
        if (filterParts[i] == '#') {
          return true;
        }
        if (i >= topicParts.length) return false;
        if (filterParts[i] != '+' && filterParts[i] != topicParts[i]) {
          return false;
        }
      }
      return filterParts.length == topicParts.length;
    }

    test('exact match', () {
      expect(topicMatch('a/b/c', 'a/b/c'), isTrue);
      expect(topicMatch('a/b/c', 'a/b/d'), isFalse);
    });

    test('# matches all remaining levels', () {
      expect(topicMatch('a/#', 'a/b'), isTrue);
      expect(topicMatch('a/#', 'a/b/c'), isTrue);
      expect(topicMatch('a/#', 'a/b/c/d'), isTrue);
      expect(topicMatch('#', 'a/b/c'), isTrue);
    });

    test('# does not match partial prefix', () {
      expect(topicMatch('a/#', 'b/c'), isFalse);
    });

    test('+ matches single level', () {
      expect(topicMatch('a/+/c', 'a/b/c'), isTrue);
      expect(topicMatch('a/+/c', 'a/x/c'), isTrue);
      expect(topicMatch('+/b/c', 'a/b/c'), isTrue);
    });

    test('+ does not match multiple levels', () {
      expect(topicMatch('a/+/c', 'a/b/d/c'), isFalse);
    });

    test('combined + and #', () {
      expect(topicMatch('+/b/#', 'a/b/c/d'), isTrue);
      expect(topicMatch('+/b/#', 'x/b/y'), isTrue);
      expect(topicMatch('+/b/#', 'a/c/d'), isFalse);
    });

    test('filter longer than topic', () {
      expect(topicMatch('a/b/c/d', 'a/b'), isFalse);
    });

    test('topic longer than filter (no wildcards)', () {
      expect(topicMatch('a/b', 'a/b/c'), isFalse);
    });

    test('empty segments', () {
      expect(topicMatch('a//c', 'a//c'), isTrue);
      expect(topicMatch('a/+/c', 'a//c'), isTrue);
    });
  });

  // ============================================================
  // Full message round-trip via pack/parse
  // ============================================================
  group('Message round-trip', () {
    test('PUBLISH QoS 0 round-trip', () {
      final original = MqttMessagePublish();
      original.fixedHead.qos = MqttQos.qos0;
      original.fixedHead.retain = true;
      original.toTopic('sensor/temp');
      original.data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]);

      final packed = original.pack();
      final buf = MqttBuffer.fromList(packed);
      final head = MqttFixedHead.readFrom(buf);
      final parsed = MqttMessagePublish.fromByteBuffer(
          head, MqttBuffer.fromList(buf.read(head.remainingLength)));

      expect(parsed.topicName, equals('sensor/temp'));
      expect(parsed.fixedHead.retain, isTrue);
      expect(parsed.fixedHead.qos, equals(MqttQos.qos0));
      expect(parsed.msgid, equals(0));
      expect(parsed.data, equals([0x48, 0x65, 0x6C, 0x6C, 0x6F]));
    });

    test('PUBLISH QoS 1 round-trip with msgid', () {
      final original = MqttMessagePublish();
      original.fixedHead.qos = MqttQos.qos1;
      original.fixedHead.dup = true;
      original.msgid = 12345;
      original.toTopic('cmd/run');
      original.data = Uint8List.fromList([0xFF]);

      final packed = original.pack();
      final buf = MqttBuffer.fromList(packed);
      final head = MqttFixedHead.readFrom(buf);
      final parsed = MqttMessagePublish.fromByteBuffer(
          head, MqttBuffer.fromList(buf.read(head.remainingLength)));

      expect(parsed.topicName, equals('cmd/run'));
      expect(parsed.fixedHead.qos, equals(MqttQos.qos1));
      expect(parsed.fixedHead.dup, isTrue);
      expect(parsed.msgid, equals(12345));
      expect(parsed.data, equals([0xFF]));
    });

    test('PUBLISH with empty payload', () {
      final original = MqttMessagePublish();
      original.fixedHead.qos = MqttQos.qos0;
      original.toTopic('status');
      original.data = Uint8List(0);

      final packed = original.pack();
      final buf = MqttBuffer.fromList(packed);
      final head = MqttFixedHead.readFrom(buf);
      final parsed = MqttMessagePublish.fromByteBuffer(
          head, MqttBuffer.fromList(buf.read(head.remainingLength)));

      expect(parsed.topicName, equals('status'));
      expect(parsed.data.length, equals(0));
    });
  });

  // ============================================================
  // Integration tests with real MQTT broker (broker.emqx.io)
  // ============================================================
  group('Integration: broker.emqx.io via TCP', () {
    const broker = 'broker.emqx.io';
    const port = 1883;

    late MqttClient client;
    late String testPrefix;

    setUp(() {
      testPrefix = 'dart_mqtt_test/${DateTime.now().millisecondsSinceEpoch}';
      final transport = XTransportTcpClient.from(broker, port);
      client = MqttClient(transport)
        ..withKeepalive(30)
        ..withClientID(
            'dart_mqtt_test_${DateTime.now().millisecondsSinceEpoch}')
        ..withClearSession(true);
    });

    tearDown(() {
      client.dispose();
    });

    test('connect and receive CONNACK', () async {
      final connacked = Completer<MqttMessageConnack>();
      client.onMqttConack((msg) {
        if (!connacked.isCompleted) connacked.complete(msg);
      });
      client.start();

      final ack = await connacked.future.timeout(const Duration(seconds: 10));
      expect(ack.returnCode, equals(MqttConnectReturnCode.connectionAccepted));
    });

    test('subscribe and receive own publish (QoS 0)', () async {
      final topic = '$testPrefix/qos0';
      final payload = Uint8List.fromList([0x48, 0x49]); // "HI"
      final received = Completer<MqttMessagePublish>();

      client.onMqttConack((msg) {
        if (msg.returnCode != MqttConnectReturnCode.connectionAccepted) return;
        client.subscribe(topic, qos: MqttQos.qos0, onMessage: (msg) {
          if (!received.isCompleted) received.complete(msg);
        });
        // Small delay to let subscribe reach the broker
        Future.delayed(const Duration(milliseconds: 500), () {
          client.publish(topic, payload: payload);
        });
      });
      client.start();

      final msg = await received.future.timeout(const Duration(seconds: 10));
      expect(msg.topicName, equals(topic));
      expect(msg.data, equals(payload));
    });

    test('subscribe and receive own publish (QoS 1)', () async {
      final topic = '$testPrefix/qos1';
      final payload = Uint8List.fromList([0x51, 0x6F, 0x53, 0x31]); // "QoS1"
      final received = Completer<MqttMessagePublish>();

      client.onMqttConack((msg) {
        if (msg.returnCode != MqttConnectReturnCode.connectionAccepted) return;
        client.subscribe(topic, qos: MqttQos.qos1, onMessage: (msg) {
          if (!received.isCompleted) received.complete(msg);
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          client.publish(topic, qos: MqttQos.qos1, payload: payload);
        });
      });
      client.start();

      final msg = await received.future.timeout(const Duration(seconds: 10));
      expect(msg.topicName, equals(topic));
      expect(msg.data, equals(payload));
    });

    test('subscribe completes future on SUBACK', () async {
      final topic = '$testPrefix/suback';
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();

      await connected.future.timeout(const Duration(seconds: 10));

      // subscribe() should complete when SUBACK is received
      await client
          .subscribe(topic, timeout: const Duration(seconds: 5))
          .timeout(const Duration(seconds: 10));
      // If we get here without timeout, the SUBACK future works correctly
    });

    test('unsubscribe stops receiving messages', () async {
      final topic = '$testPrefix/unsub';
      final payload1 = Uint8List.fromList([0x01]);
      final payload2 = Uint8List.fromList([0x02]);
      final messages = <Uint8List>[];
      final firstReceived = Completer<void>();
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      await client.subscribe(topic, onMessage: (msg) {
        messages.add(msg.data);
        if (!firstReceived.isCompleted) firstReceived.complete();
      });

      // Wait for subscribe to take effect
      await Future.delayed(const Duration(milliseconds: 300));

      // Publish first message
      await client.publish(topic, payload: payload1);
      await firstReceived.future.timeout(const Duration(seconds: 5));
      expect(messages.length, equals(1));

      // Unsubscribe
      await client.unSubscribe(topic);
      await Future.delayed(const Duration(milliseconds: 500));

      // Publish second message — should NOT be received
      await client.publish(topic, payload: payload2);
      await Future.delayed(const Duration(seconds: 2));
      expect(messages.length, equals(1));
    });

    test('wildcard + subscription receives matching messages', () async {
      final baseTopic = '$testPrefix/wild';
      final filter = '$baseTopic/+/data';
      final pubTopic = '$baseTopic/sensor1/data';
      final payload = Uint8List.fromList([0xAB]);
      final received = Completer<MqttMessagePublish>();
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      await client.subscribe(filter, onMessage: (msg) {
        if (!received.isCompleted) received.complete(msg);
      });
      await Future.delayed(const Duration(milliseconds: 500));

      await client.publish(pubTopic, payload: payload);

      final msg = await received.future.timeout(const Duration(seconds: 10));
      expect(msg.topicName, equals(pubTopic));
      expect(msg.data, equals(payload));
    });

    test('wildcard # subscription receives matching messages', () async {
      final baseTopic = '$testPrefix/multi';
      final filter = '$baseTopic/#';
      final pubTopic = '$baseTopic/a/b/c';
      final payload = Uint8List.fromList([0xCD]);
      final received = Completer<MqttMessagePublish>();
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      await client.subscribe(filter, onMessage: (msg) {
        if (!received.isCompleted) received.complete(msg);
      });
      await Future.delayed(const Duration(milliseconds: 500));

      await client.publish(pubTopic, payload: payload);

      final msg = await received.future.timeout(const Duration(seconds: 10));
      expect(msg.topicName, equals(pubTopic));
      expect(msg.data, equals(payload));
    });

    test('publish and subscribe with empty payload', () async {
      final topic = '$testPrefix/empty';
      final received = Completer<MqttMessagePublish>();
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      await client.subscribe(topic, onMessage: (msg) {
        if (!received.isCompleted) received.complete(msg);
      });
      await Future.delayed(const Duration(milliseconds: 500));

      await client.publish(topic); // no payload

      final msg = await received.future.timeout(const Duration(seconds: 10));
      expect(msg.topicName, equals(topic));
      expect(msg.data.length, equals(0));
    });

    test('two clients communicate', () async {
      // Second client
      final transport2 = XTransportTcpClient.from(broker, port);
      final client2 = MqttClient(transport2)
        ..withKeepalive(30)
        ..withClientID(
            'dart_mqtt_test2_${DateTime.now().millisecondsSinceEpoch}')
        ..withClearSession(true);

      try {
        final topic = '$testPrefix/cross';
        final payload = Uint8List.fromList([0xDE, 0xAD]);
        final received = Completer<MqttMessagePublish>();
        final c1Ready = Completer<void>();
        final c2Ready = Completer<void>();

        client.onMqttConack((msg) {
          if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
            if (!c1Ready.isCompleted) c1Ready.complete();
          }
        });
        client2.onMqttConack((msg) {
          if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
            if (!c2Ready.isCompleted) c2Ready.complete();
          }
        });

        client.start();
        client2.start();

        await Future.wait([
          c1Ready.future.timeout(const Duration(seconds: 10)),
          c2Ready.future.timeout(const Duration(seconds: 10)),
        ]);

        // client1 subscribes
        await client.subscribe(topic, onMessage: (msg) {
          if (!received.isCompleted) received.complete(msg);
        });
        await Future.delayed(const Duration(milliseconds: 500));

        // client2 publishes
        await client2.publish(topic, payload: payload);

        final msg = await received.future.timeout(const Duration(seconds: 10));
        expect(msg.topicName, equals(topic));
        expect(msg.data, equals(payload));
      } finally {
        client2.dispose();
      }
    });

    test('close sends DISCONNECT gracefully', () async {
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      // close() should send DISCONNECT and not throw
      client.close();
      // Allow transport to flush
      await Future.delayed(const Duration(milliseconds: 500));
    });

    test('subscribe timeout fires when no SUBACK arrives', () async {
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      // Close the connection so SUBSCRIBE packet won't be delivered
      client.close();
      await Future.delayed(const Duration(milliseconds: 300));

      // Subscribe with a short timeout on the disconnected client
      // _send is a no-op when not connected, so SUBACK will never arrive
      try {
        await client.subscribe(
          '$testPrefix/timeout_topic',
          timeout: const Duration(seconds: 1),
        );
        fail('Should have thrown timeout error');
      } catch (e) {
        expect(e.toString(), contains('subscribe timeout'));
      }
    });

    test('onClose callback fires when connection drops', () async {
      final connected = Completer<void>();
      final closed = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.onClose(() async {
        if (!closed.isCompleted) closed.complete();
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      // Manually close — should trigger onClose callback
      client.close();

      await closed.future.timeout(const Duration(seconds: 5));
      // If we reach here, onClose was called
    });

    test('retain flag — new subscriber receives retained message', () async {
      final topic =
          '$testPrefix/retain_${DateTime.now().millisecondsSinceEpoch}';
      final payload = Uint8List.fromList([0xEE]);
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      // Publish with retain=true
      await client.publish(topic, retain: true, payload: payload);
      await Future.delayed(const Duration(milliseconds: 500));

      // A second client subscribes and should receive the retained message
      final transport2 = XTransportTcpClient.from(broker, port);
      final client2 = MqttClient(transport2)
        ..withKeepalive(30)
        ..withClientID(
            'dart_mqtt_retain_${DateTime.now().millisecondsSinceEpoch}')
        ..withClearSession(true);

      try {
        final c2Ready = Completer<void>();
        final received = Completer<MqttMessagePublish>();

        client2.onMqttConack((msg) {
          if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
            if (!c2Ready.isCompleted) c2Ready.complete();
          }
        });
        client2.start();
        await c2Ready.future.timeout(const Duration(seconds: 10));

        client2.subscribe(topic, onMessage: (msg) {
          if (!received.isCompleted) received.complete(msg);
        });

        final msg = await received.future.timeout(const Duration(seconds: 10));
        expect(msg.topicName, equals(topic));
        expect(msg.data, equals(payload));

        // Clean up: publish empty retained message to clear it from broker
        await client.publish(topic, retain: true, payload: Uint8List(0));
      } finally {
        client2.dispose();
      }
    });

    test('allowReconnect auto-restores subscriptions', () async {
      final reconnectTransport = XTransportTcpClient.from(broker, port);
      final reconnectClient = MqttClient(
        reconnectTransport,
        allowReconnect: true,
        reconnectWait: const Duration(seconds: 1),
      )
        ..withKeepalive(30)
        ..withClientID(
            'dart_mqtt_resub_${DateTime.now().millisecondsSinceEpoch}')
        ..withClearSession(true);

      try {
        final topic = '$testPrefix/reconnect';
        final payload = Uint8List.fromList([0xBB]);
        var connackCount = 0;
        final firstConnect = Completer<void>();
        final secondConnect = Completer<void>();
        final received = Completer<MqttMessagePublish>();

        reconnectClient.onMqttConack((msg) {
          if (msg.returnCode != MqttConnectReturnCode.connectionAccepted)
            return;
          connackCount++;
          if (connackCount == 1) {
            if (!firstConnect.isCompleted) firstConnect.complete();
          } else if (connackCount == 2) {
            // reSub() is now called automatically — no manual call needed
            if (!secondConnect.isCompleted) secondConnect.complete();
          }
        });

        reconnectClient.start();
        await firstConnect.future.timeout(const Duration(seconds: 10));

        // Subscribe on first connection
        await reconnectClient.subscribe(topic, onMessage: (msg) {
          if (!received.isCompleted) received.complete(msg);
        });
        await Future.delayed(const Duration(milliseconds: 300));

        // Force disconnect — transport.close() triggers onClose → reconnect
        reconnectTransport.close();

        // Wait for reconnect
        await secondConnect.future.timeout(const Duration(seconds: 15));
        await Future.delayed(const Duration(milliseconds: 500));

        // Publish after reconnect — subscription should be restored via reSub
        await reconnectClient.publish(topic, payload: payload);

        final msg = await received.future.timeout(const Duration(seconds: 10));
        expect(msg.topicName, equals(topic));
        expect(msg.data, equals(payload));
      } finally {
        reconnectClient.dispose();
      }
    });

    test('onBeforeReconnect callback fires before reconnect', () async {
      final reconnectTransport = XTransportTcpClient.from(broker, port);
      final reconnectClient = MqttClient(
        reconnectTransport,
        allowReconnect: true,
        reconnectWait: const Duration(milliseconds: 500),
      )
        ..withKeepalive(30)
        ..withClientID(
            'dart_mqtt_before_${DateTime.now().millisecondsSinceEpoch}')
        ..withClearSession(true);

      try {
        final firstConnect = Completer<void>();
        final beforeReconnectCalled = Completer<void>();
        final secondConnect = Completer<void>();
        var connackCount = 0;

        reconnectClient.onBeforeReconnect(() async {
          if (!beforeReconnectCalled.isCompleted) {
            beforeReconnectCalled.complete();
          }
        });
        reconnectClient.onMqttConack((msg) {
          if (msg.returnCode != MqttConnectReturnCode.connectionAccepted)
            return;
          connackCount++;
          if (connackCount == 1 && !firstConnect.isCompleted) {
            firstConnect.complete();
          }
          if (connackCount == 2 && !secondConnect.isCompleted) {
            secondConnect.complete();
          }
        });

        reconnectClient.start();
        await firstConnect.future.timeout(const Duration(seconds: 10));

        // Force disconnect
        reconnectTransport.close();

        // onBeforeReconnect should fire before the second CONNACK
        await beforeReconnectCalled.future.timeout(const Duration(seconds: 10));

        // Wait for full reconnect
        await secondConnect.future.timeout(const Duration(seconds: 15));
      } finally {
        reconnectClient.dispose();
      }
    });

    test('stop() prevents further operations', () async {
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      client.stop();

      // After stop, publish should be silently ignored (no crash)
      await client.publish('$testPrefix/stopped',
          payload: Uint8List.fromList([1]));
      // If we reach here without exception, stop guard works
      await Future.delayed(const Duration(milliseconds: 300));
    });

    test('dispose() stops everything', () async {
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      await connected.future.timeout(const Duration(seconds: 10));

      client.dispose();

      // After dispose, operations should be silently ignored
      await client.publish('$testPrefix/disposed',
          payload: Uint8List.fromList([1]));
      await Future.delayed(const Duration(milliseconds: 300));
    });

    test('start() is idempotent — calling twice does not crash', () async {
      final connected = Completer<void>();

      client.onMqttConack((msg) {
        if (msg.returnCode == MqttConnectReturnCode.connectionAccepted) {
          if (!connected.isCompleted) connected.complete();
        }
      });
      client.start();
      client.start(); // second call should be no-op
      await connected.future.timeout(const Duration(seconds: 10));
    });
  });
}
