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

  /// Moves the read cursor back to [position], previously obtained
  /// from [offset]. Used to un-consume a partially parsed packet.
  void seek(int position) {
    if (position < 0 || position > length) {
      throw RangeError.range(position, 0, length, 'position');
    }
    _off = position;
  }

  void addAll(Iterable<int> iterable) {
    _buf.addAll(iterable);
  }

  /// Appends the full contents of [other] without an intermediate copy.
  void addBuffer(MqttBuffer other) {
    _buf.addAll(other._buf);
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
          'length $length, count $count, position $_off');
    }
    final result = Uint8List(count);
    result.setRange(0, count, _buf, _off);
    _off += count;
    return result;
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
      final c = s.codeUnitAt(i);

      /// http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#RFC3629
      // [MQTT-1.5.3-1] forbids unpaired surrogate code points U+D800..U+DFFF.
      // A well-formed high+low surrogate pair encodes U+10000..U+10FFFF
      // (e.g. emoji), which is valid UTF-8 and therefore allowed.
      if (c >= 0xD800 && c <= 0xDFFF) {
        if (c >= 0xDC00 || i + 1 >= s.length) {
          throw Exception('dart_mqtt::MQTTEncoding: ill-formed UTF-8: '
              'unpaired surrogate. Encodings of code points between U+D800 and U+DFFF are forbidden [MQTT-1.5.3-1].');
        }
        final low = s.codeUnitAt(i + 1);
        if (low < 0xDC00 || low > 0xDFFF) {
          throw Exception('dart_mqtt::MQTTEncoding: ill-formed UTF-8: '
              'unpaired surrogate. Encodings of code points between U+D800 and U+DFFF are forbidden [MQTT-1.5.3-1].');
        }
        // Skip the low surrogate; supplementary-plane code points carry no
        // further restrictions.
        i++;
        continue;
      }

      /// http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html
      // [MQTT-1.5.3-2]
      if (c == 0x00) {
        throw Exception('dart_mqtt::MQTTEncoding: The string has extended '
            'A UTF-8 encoded string MUST NOT include an encoding of the null character U+0000. If a receiver (Server or Client) receives a Control Packet containing U+0000 it MUST close the Network Connection [MQTT-1.5.3-2].');
      }
      if (c >= 0x0001 && c <= 0x001F) {
        throw Exception('dart_mqtt::MQTTEncoding: The string has extended '
            'UTF characters, control string are not supported');
      }

      if (c >= 0x007F && c <= 0x009F) {
        throw Exception('dart_mqtt::MQTTEncoding: The string has extended '
            'UTF characters, control string are not supported');
      }

      // TODO: A UTF-8 encoded sequence 0xEF 0xBB 0xBF is always to be interpreted to mean U+FEFF ("ZERO WIDTH NO-BREAK SPACE") wherever it appears in a string and MUST NOT be skipped over or stripped off by a packet receiver [MQTT-1.5.3-3].
    }
    return s;
  }
}
