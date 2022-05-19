part of '../mqtt.dart';

class MqttMessageSubscribe extends MqttMessage {
  int _messageID = 0;
  final List<String> _topics = [];
  final List<MqttQos> _qoss = [];

  List<String> get topics => _topics;

  void withMessageID(int val) {
    _messageID = val;
  }

  void add(String topic, MqttQos qos) {
    _topics.add(topic);
    _qoss.add(qos);
  }

  MqttMessageSubscribe.withTopic(int val, String topic, MqttQos qos) {
    fixedHead = MqttFixedHead().asType(MqttMessageType.subscribe);
    fixedHead.qos = MqttQos.qos1;
    withMessageID(val);
    add(topic, qos);
  }

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessageSubscribe.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
  }

  @override
  void writeTo(MqttBuffer messageStream) {
    fixedHead.messageType = MqttMessageType.subscribe;
    fixedHead.qos = MqttQos.qos1;
    MqttBuffer _variableHeader = MqttBuffer();
    _variableHeader.writeInteger(_messageID);
    for (var i = 0; i < _topics.length; i++) {
      _variableHeader.writeUtf8String(_topics[i]);
      _variableHeader.writeBits(_qoss[i].index);
    }
    fixedHead.remainingLength = _variableHeader.length;
    messageStream.addAll(fixedHead.headerBytes());
    messageStream.addAll(_variableHeader.bytes);
  }

  @override
  String toString() {
    var str = fixedHead.toString();
    str = str +
        "\x1b[39mId \x1b[0m" +
        fixedHead.blue(_messageID.toString().padRight(6));
    for (var i = 0; i < _qoss.length; i++) {
      str = str +
          fixedHead.yellow(_topics[i]) +
          "\x1b[39;2m(Qos:${_qoss[i].index.toString()})\x1b[0m  ";
    }
    return str;
    //  +
    // // _topics.map((e) => e)
    // // _topics.where((element) => false)

    // // "\x1b[39m, Topic \x1b[0m" +
    // fixedHead.yellow(_topics.join(","));
  }
}
