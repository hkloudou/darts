part of '../mqtt.dart';

class MqttMessagePingresp extends MqttMessage {
  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessagePingresp.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
  }
}
