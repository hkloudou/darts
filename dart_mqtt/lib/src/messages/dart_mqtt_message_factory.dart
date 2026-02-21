part of '../mqtt.dart';

class MqttMessageFactory {
  /// Gets an instance of an MqttMessage based on the message type requested.
  static MqttMessage getMessage(
      MqttFixedHead header, MqttBuffer messageStream) {
    switch (header.messageType) {
      case MqttMessageType.connack:
        return MqttMessageConnack.fromByteBuffer(header, messageStream);
      case MqttMessageType.pingresp:
        return MqttMessagePingresp.fromByteBuffer(header, messageStream);
      case MqttMessageType.suback:
        return MqttMessageSuback.fromByteBuffer(header, messageStream);
      case MqttMessageType.publish:
        return MqttMessagePublish.fromByteBuffer(header, messageStream);
      case MqttMessageType.puback:
        return MqttMessagePuback.fromByteBuffer(header, messageStream);
      case MqttMessageType.unsuback:
        return MqttMessageUnSuback.fromByteBuffer(header, messageStream);
      default:
    }
    throw Exception(
        'Unsupported message type: ${header.messageType.name} (${header.toString()})');
  }

  static MqttFixedHead readHead(MqttBuffer messageStream) {
    try {
      var head = MqttFixedHead.readFrom(messageStream);
      return head;
    } on Exception catch (e) {
      throw Exception('The data provided in the message stream was not a '
          'valid MQTT Message, '
          'exception is $e');
    }
  }

  static MqttMessage readMessage(MqttFixedHead head, MqttBuffer messageStream) {
    try {
      if (messageStream.availableBytes < head.remainingLength) {
        throw Exception(
            'Available bytes:${messageStream.availableBytes} is less than the message size:${head.remainingLength}');
      }
      return getMessage(head, messageStream);
    } on Exception catch (e) {
      throw Exception('The data provided in the message stream was not a '
          'valid MQTT Message, '
          'exception is $e');
    }
  }
}
