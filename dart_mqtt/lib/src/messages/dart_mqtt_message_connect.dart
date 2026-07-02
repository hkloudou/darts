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
    MqttBuffer variableHeader = MqttBuffer();

    // 3.1.2.1 Protocol Name
    variableHeader.writeUtf8String("MQTT");
    // 3.1.2.2 Protocol Level
    variableHeader.writeBits(4);
    // variableHeader.writeBits(value)

    // 3.1.2.3 Connect Flags
    variableHeader.writeBits(_connectFlagByte());

    // 3.1.2.10 Keep Alive
    variableHeader.writeInteger(_keepalive);

    //3.1.3 Payload
    MqttBuffer body = MqttBuffer();
    // 3.1.3.1 Client Identifier
    body.writeUtf8String(_clientIdentifier);
    // TODO: will support
    // if (willFlag) {
    //   body.writeUtf8String("will");
    //   body.writeUtf8String("");
    // }
    if (usernameFlag) {
      body.writeUtf8String(_username);
    }

    if (passwordFlag) {
      body.writeUtf8String(_password);
    }
    fixedHead.remainingLength = variableHeader.length + body.length;
    messageStream.addAll(fixedHead.headerBytes());
    messageStream.addBuffer(variableHeader);
    messageStream.addBuffer(body);
  }
}
