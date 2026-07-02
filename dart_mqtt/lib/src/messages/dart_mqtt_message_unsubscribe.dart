part of '../mqtt.dart';

class MqttMessageUnSubscribe extends MqttMessage {
  int _messageID = 0;
  final List<String> _topics = [];

  void withMessageID(int val) {
    _messageID = val;
  }

  void add(String topic) {
    _topics.add(topic);
  }

  MqttMessageUnSubscribe.withTopic(List<String> topics) {
    fixedHead = MqttFixedHead().asType(MqttMessageType.unsubscribe);
    fixedHead.qos = MqttQos.qos1;
    for (var item in topics) {
      add(item);
    }
  }

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessageUnSubscribe.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
  }

  @override
  void writeTo(MqttBuffer messageStream) {
    fixedHead.qos = MqttQos.qos1;
    fixedHead.messageType = MqttMessageType.unsubscribe;
    MqttBuffer variableHeader = MqttBuffer();
    variableHeader.writeInteger(_messageID);
    for (var i = 0; i < _topics.length; i++) {
      variableHeader.writeUtf8String(_topics[i]);
    }
    fixedHead.remainingLength = variableHeader.length;
    messageStream.addAll(fixedHead.headerBytes());
    messageStream.addBuffer(variableHeader);
  }

  @override
  String toString() =>
      "$fixedHead\x1b[39mId \x1b[0m${fixedHead.blue(_messageID.toString().padRight(6))}${fixedHead.yellow(_topics.join(","))}";
}
