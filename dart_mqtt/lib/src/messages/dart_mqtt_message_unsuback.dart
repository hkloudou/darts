part of '../mqtt.dart';

class MqttMessageUnSuback extends MqttMessage {
  int msgid = 0;

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessageUnSuback.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
  }
  @override
  void readFrom(MqttBuffer messageStream) {
    msgid = messageStream.readInteger();
  }

  @override
  String toString() =>
      fixedHead.toString() +
      "id: " +
      fixedHead.green(msgid.toString().padRight(6));
}
