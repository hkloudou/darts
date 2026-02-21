part of '../mqtt.dart';

class MqttFixedHead {
  MqttFixedHead();

  MqttFixedHead.readFrom(MqttBuffer buf) {
    _fixedHeaderByte = buf.readBits();
    _remainingLength = _calculateLength(_readLengthBytes(buf));
  }

  MqttFixedHead asType(MqttMessageType type) {
    messageType = type;
    return this;
  }

  /// Gets or sets the size of the variable header + payload
  /// section of the message.
  /// The size of the variable header + payload.
  int get remainingLength => _remainingLength;

  set remainingLength(int value) {
    if (value < 0 || value > 268435455) {
      throw Exception('dart-mqtt::InvalidPayloadSizeException: The size of the '
          'payload (value bytes) must '
          'be equal to or greater than 0 and less than 268435455 bytes');
    }
    _remainingLength = value;
  }

  Uint8List _readLengthBytes(MqttBuffer buf) {
    final lengthBytes = <int>[];
    int sizeByte;
    var byteCount = 0;
    do {
      if (buf.availableBytes == 0) {
        throw Exception(
            'dart_mqtt: Unexpected end of buffer while reading remaining length');
      }
      sizeByte = buf.readBits();
      lengthBytes.add(sizeByte);
      byteCount++;
    } while (byteCount < 4 && (sizeByte & 0x80) == 0x80);

    if ((sizeByte & 0x80) == 0x80) {
      throw Exception(
          'dart_mqtt: Invalid remaining length encoding: exceeds 4 bytes');
    }

    return Uint8List.fromList(lengthBytes);
  }

  int _calculateLength(Uint8List lengthBytes) {
    var tmpremainingLength = 0;
    var multiplier = 1;

    for (final currentByte in lengthBytes) {
      tmpremainingLength += (currentByte & 0x7f) * multiplier;
      multiplier *= 0x80;
    }
    return tmpremainingLength;
  }

  /// Calculates and return the bytes that represent the
  /// remaining length of the message.
  Uint8List _getRemainingLengthBytes() {
    final lengthBytes = <int>[];
    var payloadCalc = _remainingLength;

    // Generate a byte array based on the message size, splitting it up into
    // 7 bit chunks, with the 8th bit being used to indicate 'one more to come'
    do {
      var nextByteValue = payloadCalc % 128;
      payloadCalc = payloadCalc ~/ 128;
      if (payloadCalc > 0) {
        nextByteValue = nextByteValue | 0x80;
      }
      lengthBytes.add(nextByteValue);
    } while (payloadCalc > 0);

    return Uint8List.fromList(lengthBytes);
  }

  /// Gets the value of the Mqtt header as a byte array
  Uint8List headerBytes() {
    final headerBytes = <int>[];
    headerBytes.add(_fixedHeaderByte);
    headerBytes.addAll(_getRemainingLengthBytes());
    return Uint8List.fromList(headerBytes);
  }

  /// 2.2 Fixed header
  ///
  /// Figure 2.2 - Fixed header format
  ///
  /// `byte 1`bit 7-4: MQTT Control Packet type
  ///
  /// `byte 1`bit 3-0: Flags specific to each MQTT Control Packet type
  ///
  /// `byte 2...` Remaining Length
  int _fixedHeaderByte = 0;
  int _remainingLength = 0;

  /// 2.2 Fixed header messageType 0b11110000(`bit 7-4(0-15)`)
  MqttMessageType get messageType =>
      MqttMessageType.values[(_fixedHeaderByte & 240) >> 4];
  set messageType(MqttMessageType value) {
    _fixedHeaderByte = _fixedHeaderByte | 240; //  fill
    _fixedHeaderByte = _fixedHeaderByte ^ 240; //  clear
    _fixedHeaderByte = _fixedHeaderByte | ((value.index << 4 & 240));
  }

  /// 2.2 Fixed header retain 0b00001000(`bit 3`)
  bool get dup => (_fixedHeaderByte & 8) == 8;
  set dup(bool value) {
    _fixedHeaderByte = (_fixedHeaderByte & 0xFF) | 8;
    if (!value) _fixedHeaderByte = _fixedHeaderByte ^ 8;
  }

  /// 2.2 Fixed header qos 0b00000110(`bit 2-1(0-3)`)
  MqttQos get qos => MqttQos.values[(_fixedHeaderByte & 6) >> 1];
  set qos(MqttQos value) {
    _fixedHeaderByte = _fixedHeaderByte | 6; //  fill
    _fixedHeaderByte = _fixedHeaderByte ^ 6; //  clear
    _fixedHeaderByte = _fixedHeaderByte | ((value.index << 1 & 6));
  }

  /// 2.2 Fixed header retain 0b00000001(`bit 0`)
  bool get retain => _fixedHeaderByte & 1 == 1;
  set retain(bool value) {
    _fixedHeaderByte = (_fixedHeaderByte & 0xFF) | 1;
    if (!value) _fixedHeaderByte = _fixedHeaderByte ^ 1;
  }

  String yellow(String val) => "\x1b[33m$val\x1b[0m";
  String red(String val) => "\x1b[31m$val\x1b[0m";
  String green(String val) => "\x1b[32m$val\x1b[0m";
  String blue(String val) => "\x1b[34m$val\x1b[0m";
  String cyan(String val) => "\x1b[36m$val\x1b[0m";
  String whitebold(String val) => "\x1b[39;1m$val\x1b[0m";
  String white(String val) => "\x1b[39m$val\x1b[0m";
  String _title(String val) => "\x1b[39m$val\x1b[0m";
  String qosColor(int val) {
    switch (val) {
      case 0:
        return "\x1b[39;2m$val\x1b[0m";
      case 1:
        return "\x1b[33;1m$val\x1b[0m";
      case 2:
        return "\x1b[31;1m$val\x1b[0m";
      default:
        return "\x1b[31;1m$val\x1b[0m";
    }
  }

  @override
  String toString() =>
      '\x1b[33;1m${messageType.name.padRight(12)}\x1b[0m ${_title("DUP ")}${dup ? green("✔") : red("✗")}'
      '${_title(" RETAIN ")}${retain ? green("✔") : red("✗")}${_title(" Qos ")}${qosColor(qos.index)}${_title(" Size ")}\x1b[39;2m${(_remainingLength.toString().padRight(10))}\x1b[0m';
}
