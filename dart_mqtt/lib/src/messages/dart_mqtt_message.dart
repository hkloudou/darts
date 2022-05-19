part of '../mqtt.dart';

abstract class MqttMessage implements ITransportPacket {
  late MqttFixedHead fixedHead;

  void readFrom(MqttBuffer messageStream) {}
  void writeTo(MqttBuffer messageStream) {
    messageStream.addAll(fixedHead.headerBytes());
  }

  @override
  Uint8List pack() {
    var buf = MqttBuffer();
    writeTo(buf);
    return buf.bytes;
  }

  @override
  String toString() => fixedHead.toString();
}
