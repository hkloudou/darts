/// 2.2.1 MQTT Control Packet type
///
/// http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Table_2.1_-
///
/// /// Position: byte 1, bits 7-4.
///
/// Represented as a 4-bit unsigned value, the values are listed in Table 2.1 - Control packet types.
enum MqttMessageType {
  reserved1,
  connect,
  connack,
  publish,
  puback,
  pubrec,
  pubrel,
  pubcomp,
  subscribe,
  suback,
  unsubscribe,
  unsuback,
  pingreq,
  pingresp,
  disconnect,
  reserved2,
}

/// 2.2.2 Flags
///
/// http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Table_2.2_-
///
/// The remaining bits [3-0] of byte 1 in the fixed header contain flags specific to each MQTT Control Packet type as listed in the Table 2.2 - Flag Bits below. Where a flag bit is marked as “Reserved” in Table 2.2 - Flag Bits, it is reserved for future use and MUST be set to the value listed in that table [MQTT-2.2.2-1]. If invalid flags are received, the receiver MUST close the Network Connection [MQTT-2.2.2-2]. See Section 4.8 for details about handling errors.
enum MqttQos { qos0, qos1, qos2, reserved }

enum MqttConnectReturnCode {
  /// Connection accepted
  connectionAccepted,

  /// Invalid protocol version
  unacceptedProtocolVersion,

  /// Invalid client identifier
  identifierRejected,

  /// Broker unavailable
  brokerUnavailable,

  /// Invalid username or password
  badUsernameOrPassword,

  /// Not authorised
  notAuthorized,

  /// Unsolicited, i.e. not requested by the client
  unsolicited,

  /// Solicited, i.e. requested by the client
  solicited,

  /// Default
  noneSpecified
}
