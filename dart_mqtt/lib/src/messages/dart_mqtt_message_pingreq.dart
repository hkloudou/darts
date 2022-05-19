part of '../mqtt.dart';

class MqttMessagePingreq extends MqttMessage {
  MqttMessagePingreq() {
    fixedHead = MqttFixedHead().asType(MqttMessageType.pingreq);
  }

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessagePingreq.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
  }
}
