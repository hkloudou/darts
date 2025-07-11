part of '../mqtt.dart';

class MqttMessagePublish extends MqttMessage {
  MqttMessagePublish() {
    fixedHead = MqttFixedHead().asType(MqttMessageType.publish);
  }

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessagePublish.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
    readFrom(messageStream);
  }
  String _topicName = "";

  String get topicName => _topicName;
  int msgid = 0;
  Uint8List data = Uint8List(0);

  /// Sets the topic to publish data to.
  MqttMessagePublish toTopic(String topicName) {
    _topicName = topicName;
    return this;
  }

  @override
  void readFrom(MqttBuffer messageStream) {
    var off = messageStream.offset;
    _topicName = messageStream.readUtf8String();
    if (fixedHead.qos.index > 0) {
      msgid = messageStream.readInteger();
    }
    data = messageStream
        .read(fixedHead.remainingLength - (messageStream.offset - off));
  }

  @override
  void writeTo(MqttBuffer messageStream) {
    fixedHead.messageType = MqttMessageType.publish;
    MqttBuffer _variableHeader = MqttBuffer();
    _variableHeader.writeUtf8String(_topicName);
    if (fixedHead.qos.index > 0) {
      _variableHeader.writeInteger(msgid);
    }
    fixedHead.remainingLength = _variableHeader.length + data.length;
    messageStream.addAll(fixedHead.headerBytes());
    messageStream.addAll(_variableHeader.bytes);
    messageStream.addAll(data);
  }

  @override
  String toString() =>
      fixedHead.toString() +
      "\x1b[39mId \x1b[0m" +
      fixedHead.blue(msgid.toString().padRight(6)) +
      // "\x1b[39m, Topic \x1b[0m" +
      fixedHead.yellow(_topicName) +
      "\x1b[39;2m(Size:${data.length.toString()})\x1b[0m";
}
