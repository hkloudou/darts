part of '../mqtt.dart';

class MqttMessageSuback extends MqttMessage {
  int msgid = 0;
  List<int> returnCodes = [];

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessageSuback.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
    readFrom(messageStream);
  }
  @override
  void readFrom(MqttBuffer messageStream) {
    msgid = messageStream.readInteger();
    final count = fixedHead.remainingLength - 2;
    returnCodes = List.generate(count, (_) => messageStream.readBits());
  }

  String _code() {
    if (returnCodes.isEmpty) return '';
    final first = returnCodes.first;
    if (first <= 2) {
      return fixedHead.green("✔ MaxQos = $first");
    }
    return fixedHead
        .red("✗ Code =  0x${first.toRadixString(16).padLeft(2, "0")}");
  }

  @override
  String toString() =>
      fixedHead.toString() +
      "\x1b[39mId \x1b[0m" +
      fixedHead.blue(msgid.toString().padRight(6)) +
      // "\x1b[39m, \x1b[0m" +
      _code();
}
