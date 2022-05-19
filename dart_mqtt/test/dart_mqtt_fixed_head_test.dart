import 'package:dart_mqtt/src/mqtt.dart';
import 'package:dart_mqtt/dart_mqtt.dart';
import 'package:test/test.dart';

void main() {
  group('Mqtt fixedHeader', () {
    var msg = MqttFixedHead();
    setUp(() {});

    test('type', () {
      expect(msg.messageType.index, equals(0));
      for (var i = 0; i < MqttMessageType.values.length; i++) {
        msg.messageType = MqttMessageType.values[i];
        expect(msg.messageType.index, equals(i));
      }
      print(msg.messageType);
    });
    test('dup', () {
      expect(msg.dup, isFalse);
      msg.dup = true;
      expect(msg.dup, isTrue);
      msg.dup = false;
      expect(msg.dup, isFalse);
      msg.dup = true;
      expect(msg.dup, isTrue);
      msg.dup = false;
      expect(msg.dup, isFalse);
    });
    test('retain', () {
      expect(msg.retain, isFalse);
      msg.retain = true;
      expect(msg.retain, isTrue);
      msg.retain = false;
      expect(msg.retain, isFalse);
      msg.retain = true;
      expect(msg.retain, isTrue);
      msg.retain = false;
      expect(msg.retain, isFalse);
    });

    test('qos', () {
      expect(msg.qos.index, equals(0));
      for (var i = 0; i < MqttQos.values.length; i++) {
        msg.qos = MqttQos.values[i];
        expect(msg.qos.index, equals(i));
      }
    });
  });
}
