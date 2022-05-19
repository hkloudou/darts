part of '../mqtt.dart';

class MqttMessageConnect extends MqttMessage {
  /// Reserved1
  bool reserved1 = false;

  /// Clean start
  bool cleanStart = false;

  /// Will
  final bool _willFlag = false;

  /// Will Qos
  MqttQos willQos = MqttQos.qos0;

  /// Will retain
  bool willRetain = false;

  /// Password present
  bool get passwordFlag => _password.isNotEmpty;

  /// Username present
  bool get usernameFlag => _username.isNotEmpty;

  String _username = "";
  String _password = "";

  int _keepalive = 0;
  String _clientIdentifier = "";

  /// Return the connect flag value
  int _connectFlagByte() =>
      (reserved1 ? 1 : 0) |
      (cleanStart ? 1 : 0) << 1 |
      (_willFlag ? 1 : 0) << 2 |
      (willQos.index) << 3 |
      (willRetain ? 1 : 0) << 5 |
      (passwordFlag ? 1 : 0) << 6 |
      (usernameFlag ? 1 : 0) << 7;

  MqttMessageConnect() {
    fixedHead = MqttFixedHead().asType(MqttMessageType.connect);
  }

  MqttMessageConnect withKeepalive(int t) {
    _keepalive = t;
    return this;
  }

  int getKeepalive() => _keepalive;

  MqttMessageConnect withAuth(String username, String password) {
    _username = username;
    _password = password;
    return this;
  }

  MqttMessageConnect withClientID(String clientID) {
    _clientIdentifier = clientID;
    return this;
  }

  @override
  void writeTo(MqttBuffer messageStream) {
    fixedHead.messageType = MqttMessageType.connect;
    MqttBuffer _variableHeader = MqttBuffer();

    // 3.1.2.1 Protocol Name
    _variableHeader.writeUtf8String("MQTT");
    // 3.1.2.2 Protocol Level
    _variableHeader.writeBits(4);
    // _variableHeader.writeBits(value)

    // 3.1.2.3 Connect Flags
    _variableHeader.writeBits(_connectFlagByte());

    // 3.1.2.10 Keep Alive
    _variableHeader.writeInteger(_keepalive);

    //3.1.3 Payload
    MqttBuffer _body = MqttBuffer();
    // 3.1.3.1 Client Identifier
    _body.writeUtf8String(_clientIdentifier);
    // TODO: will support
    // if (willFlag) {
    //   _body.writeUtf8String("will");
    //   _body.writeUtf8String("");
    // }
    if (usernameFlag) {
      _body.writeUtf8String(_username);
    }

    if (passwordFlag) {
      _body.writeUtf8String(_password);
    }
    fixedHead.remainingLength = _variableHeader.length + _body.length;
    messageStream.addAll(fixedHead.headerBytes());
    messageStream.addAll(_variableHeader.bytes);
    messageStream.addAll(_body.bytes);
  }
}
