part of '../mqtt.dart';

/// MQTT PUBACK message — sent by broker to acknowledge a QoS 1 PUBLISH.
///
/// Section 3.4: The PUBACK Packet is the response to a PUBLISH Packet
/// with QoS level 1.
class MqttMessagePuback extends MqttMessage {
  int msgid = 0;

  MqttMessagePuback.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
    readFrom(messageStream);
  }

  @override
  void readFrom(MqttBuffer messageStream) {
    msgid = messageStream.readInteger();
  }

  @override
  String toString() =>
      fixedHead.toString() +
      "\x1b[39mId \x1b[0m" +
      fixedHead.green(msgid.toString().padRight(6));
}
