part of '../mqtt.dart';

class MqttMessageSuback extends MqttMessage {
  int msgid = 0;
  int returnCode = 0;

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessageSuback.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
    readFrom(messageStream);
  }
  @override
  void readFrom(MqttBuffer messageStream) {
    msgid = messageStream.readInteger();
    returnCode = messageStream.readBits();
  }

  String _code() {
    if (returnCode <= 2) {
      return fixedHead.green("✔ MaxQos = " + returnCode.toString());
    }
    return fixedHead
        .red("✗ Code =  0x" + returnCode.toRadixString(16).padLeft(2, "0"));
  }

  @override
  String toString() =>
      fixedHead.toString() +
       "\x1b[39mId \x1b[0m" +
      fixedHead.blue(msgid.toString().padRight(6)) +
      // "\x1b[39m, \x1b[0m" +
      _code();
}
