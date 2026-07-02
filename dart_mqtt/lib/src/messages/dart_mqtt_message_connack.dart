part of '../mqtt.dart';

class MqttMessageConnack extends MqttMessage {
  MqttConnectReturnCode returnCode = MqttConnectReturnCode.noneSpecified;

  /// Initializes a new instance of the MqttConnectAckMessage class.
  MqttMessageConnack.fromByteBuffer(
      MqttFixedHead header, MqttBuffer messageStream) {
    fixedHead = header;
    readFrom(messageStream);
  }
  @override
  void readFrom(MqttBuffer messageStream) {
    super.readFrom(messageStream);
    final _ = messageStream.readBits();
    final ret = messageStream.readBits();
    // MQTT 3.1.1 Table 3.1 defines return codes 0-5; 6-255 are reserved and
    // must be treated as malformed.
    if (ret > MqttConnectReturnCode.notAuthorized.index) {
      throw Exception(
          'dart_mqtt: Unknown CONNACK return code: 0x${ret.toRadixString(16)}');
    }
    returnCode = MqttConnectReturnCode.values[ret];
  }

  String _status(MqttConnectReturnCode code) {
    switch (code) {
      case MqttConnectReturnCode.connectionAccepted:
        return "\x1b[32;1m${code.name}\x1b[0m";
      case MqttConnectReturnCode.badUsernameOrPassword:
      case MqttConnectReturnCode.notAuthorized:
        return "\x1b[33;1m${code.name}\x1b[0m";
      default:
        return "\x1b[31;1m${code.name}\x1b[0m";
    }
  }

  @override
  String toString() => "$fixedHead[${_status(returnCode)}]";
}
