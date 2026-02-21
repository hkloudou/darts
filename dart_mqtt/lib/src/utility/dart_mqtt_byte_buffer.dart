part of '../mqtt.dart';

/// http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html
///
/// 1.5 Data representations
class MqttBuffer {
  final List<int> _buf = <int>[];
  int _off = 0;

  /// offset
  int get offset => _off;

  /// Length
  int get length => _buf.length;

  /// Available bytes
  int get availableBytes => length - _off;

  void rewind() {
    _off = 0;
  }

  void addAll(Iterable<int> iterable) {
    _buf.addAll(iterable);
  }

  Uint8List get bytes => Uint8List.fromList(_buf);

  MqttBuffer() {
    clear();
  }
  MqttBuffer.fromList(Iterable<int> elements) {
    clear();
    addAll(elements);
  }

  /// Shrink the buffer
  void shrink() {
    _buf.removeRange(0, _off);
    _off = 0;
  }

  void clear() {
    _buf.clear();
    _off = 0;
  }

  /// Reads a sequence of bytes from the current
  /// buffer and advances the position within the buffer
  /// by the number of bytes read.
  Uint8List read(int count) {
    if ((length < count) || (_off + count) > length) {
      throw Exception('mqtt_client::ByteBuffer: The buffer did not have '
          'enough bytes for the read operation '
          'length $length, count $count, position $_off, buffer $_buf');
    }
    final tmp = <int>[];
    tmp.addAll(_buf.getRange(_off, _off + count));
    _off += count;
    return Uint8List.fromList(tmp);
  }

  /// Read a bits(1 byte)
  ///
  /// 1.5.1 Bits
  ///
  /// Bits in a byte are labeled 7 through 0. Bit number 7 is the most significant bit, the least significant bit is assigned bit number 0.
  int readBits() {
    if (_off >= _buf.length) {
      throw Exception('mqtt_client::ByteBuffer: The buffer did not have '
          'enough bytes for the read operation. '
          'Position $_off is beyond buffer length ${_buf.length}');
    }
    final tmp = _buf[_off];
    _off++;
    return tmp;
  }

  /// Write a bits(1 byte)
  ///
  /// 1.5.1 Bits
  ///
  /// Bits in a byte are labeled 7 through 0. Bit number 7 is the most significant bit, the least significant bit is assigned bit number 0.
  void writeBits(int value) {
    _buf.add(value);
  }

  /// Read a integer(2 bytes)
  ///
  /// 1.5.2 Integer data values
  ///
  /// Integer data values are 16 bits in big-endian
  ///
  /// order: the high order byte precedes the lower order byte.
  ///
  /// This means that a 16-bit word is presented on the network as Most Significant Byte (MSB)
  ///
  /// followed by Least Significant Byte (LSB).
  int readInteger() {
    final high = readBits();
    final low = readBits();
    return (high << 8) + low;
  }

  /// Write a integer(2 bytes)
  ///
  /// 1.5.2 Integer data values
  ///
  /// Integer data values are 16 bits in big-endian
  ///
  /// order: the high order byte precedes the lower order byte.
  ///
  /// This means that a 16-bit word is presented on the network as Most Significant Byte (MSB)
  ///
  /// followed by Least Significant Byte (LSB).
  void writeInteger(int value) {
    writeBits((value & 0xFFFF) >> 8);
    writeBits(value & 0xFF);
  }

  /// Write a utf-8 string(2 bytes integer length,then follow data)
  ///
  /// 1.5.3 UTF-8 encoded strings
  ///
  /// Text fields in the Control Packets described later are encoded as UTF-8 strings. UTF-8 [RFC3629] is an efficient encoding of Unicode [Unicode] characters that optimizes the encoding of ASCII characters in support of text-based communications.
  ///
  /// Each of these strings is prefixed with a two byte length field that gives the number of bytes in a UTF-8 encoded string itself, as illustrated in Figure 1.1 Structure of UTF-8 encoded strings below. Consequently there is a limit on the size of a string that can be passed in one of these UTF-8 encoded string components; you cannot use a string that would encode to more than 65535 bytes.
  ///
  /// Unless stated otherwise all UTF-8 encoded strings can have any length in the range 0 to 65535 bytes.
  ///
  void writeUtf8String(String input) {
    final bts = utf8.encode(_validateString(input));
    if (bts.length > 65535) {
      throw Exception(
          'dart_mqtt: UTF-8 string exceeds maximum length of 65535 bytes');
    }
    writeInteger(bts.length);
    addAll(bts);
  }

  /// Read a utf-8 string(2 bytes integer length,then follow data)
  ///
  /// 1.5.3 UTF-8 encoded strings
  ///
  /// Text fields in the Control Packets described later are encoded as UTF-8 strings. UTF-8 [RFC3629] is an efficient encoding of Unicode [Unicode] characters that optimizes the encoding of ASCII characters in support of text-based communications.
  ///
  /// Each of these strings is prefixed with a two byte length field that gives the number of bytes in a UTF-8 encoded string itself, as illustrated in Figure 1.1 Structure of UTF-8 encoded strings below. Consequently there is a limit on the size of a string that can be passed in one of these UTF-8 encoded string components; you cannot use a string that would encode to more than 65535 bytes.
  ///
  /// Unless stated otherwise all UTF-8 encoded strings can have any length in the range 0 to 65535 bytes.
  String readUtf8String() => _validateString(utf8.decode(read(readInteger())));

  static String _validateString(String s) {
    for (var i = 0; i < s.length; i++) {
      /// http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#RFC3629
      // [MQTT-1.5.3-1] U+D800 and U+DFFF
      if (s.codeUnitAt(i) >= 0xD800 && s.codeUnitAt(i) <= 0xDFFF) {
        throw Exception('dart_mqtt::MQTTEncoding: The string has extended '
            'The character data in a UTF-8 encoded string MUST be well-formed UTF-8 as defined by the Unicode specification [Unicode] and restated in RFC 3629 [RFC3629]. In particular this data MUST NOT include encodings of code points between U+D800 and U+DFFF. If a Server or Client receives a Control Packet containing ill-formed UTF-8 it MUST close the Network Connection [MQTT-1.5.3-1].');
      }

      /// http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html
      // [MQTT-1.5.3-2]
      if (s.codeUnitAt(i) == 0x00) {
        throw Exception('dart_mqtt::MQTTEncoding: The string has extended '
            'A UTF-8 encoded string MUST NOT include an encoding of the null character U+0000. If a receiver (Server or Client) receives a Control Packet containing U+0000 it MUST close the Network Connection [MQTT-1.5.3-2].');
      }
      if (s.codeUnitAt(i) >= 0x0001 && s.codeUnitAt(i) <= 0x001F) {
        throw Exception('dart_mqtt::MQTTEncoding: The string has extended '
            'UTF characters, control string are not supported');
      }

      if (s.codeUnitAt(i) >= 0x007F && s.codeUnitAt(i) <= 0x009F) {
        throw Exception('dart_mqtt::MQTTEncoding: The string has extended '
            'UTF characters, control string are not supported');
      }

      // TODO: A UTF-8 encoded sequence 0xEF 0xBB 0xBF is always to be interpreted to mean U+FEFF ("ZERO WIDTH NO-BREAK SPACE") wherever it appears in a string and MUST NOT be skipped over or stripped off by a packet receiver [MQTT-1.5.3-3].

      // mqtt_client
      // if (s.codeUnitAt(i) > 0x7F) {
      //   throw Exception(
      //       'dart_mqtt::MQTTEncoding: The output string has extended '
      //       'UTF characters, which are not supported');
      // }
    }
    return s;
  }
}
