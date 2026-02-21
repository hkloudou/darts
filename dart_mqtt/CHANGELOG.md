## 1.0.7

### Bug Fixes
- Fixed UNSUBACK message parsing: `readFrom()` was never called, message ID always returned 0
- Fixed remaining length decoding consuming an extra byte on malformed packets
- Fixed PUBLISH with QoS > 0 sending reserved message ID 0 (MQTT-2.3.1 violation)
- Fixed CONNACK throwing generic `RangeError` for unknown return codes, now throws descriptive exception
- Fixed `MessageIdentifierDispenser` singleton causing shared state across multiple clients
- Fixed pinger timer continuing indefinitely after `stop()` was called
- Fixed reconnect proceeding after `stop()` due to missing guard in delay callback
- Fixed pending subscribe Futures never completing after reconnect (`_idTopic.clear()` without cleanup)
- Fixed SUBACK only reading one return code when multiple topics were subscribed
- Fixed UTF-8 surrogate validation: U+D800 and U+DFFF boundaries were not rejected (off-by-one)
- Fixed control character validation: U+0001, U+001F, U+007F, U+009F boundaries were not rejected
- Added UTF-8 string 65535 byte length limit per MQTT-1.5.3
- Fixed `close()` not sending DISCONNECT packet before closing connection (MQTT-3.14)

### API Changes
- Removed `futureWaitData` parameter from `subscribe()` (mixed concerns, unnecessary complexity)
- Removed `force` parameter from `subscribe()` (client-side caching with timer leak)
- Auto `reSub()` on CONNACK acceptance — no longer requires manual call after reconnect
- `MqttMessageSuback.returnCode` changed to `returnCodes` (list) for multi-topic support

### New Features
- Added `MqttMessagePuback` for QoS 1 PUBACK handling
- Added `MqttMessageDisconnect` for clean connection shutdown
- Added MQTT topic wildcard matching (`+` single-level, `#` multi-level) per spec section 4.7

### Tests
- Added 84 tests (65 unit tests + 19 integration tests against broker.emqx.io)

## 1.0.6
### Bug Fixes
- Fixed critical RangeError when reading incomplete MQTT packets from buffer (resolves #5)
- Added boundary checks to prevent buffer overflow in readBits() method
- Fixed circular import issue in mqtt.dart that caused compilation errors
- Corrected variable naming: `_stoped` → `_stopped` throughout codebase
- Fixed QoS message serialization bug in publish message (msgid written to wrong buffer)
- Fixed bit operation precedence issues in MQTT header manipulation
- Added safety checks to prevent infinite loops when reading malformed remaining length
- Improved exception messages in message factory with proper error descriptions
- Enhanced buffer processing logic to use availableBytes instead of total length
- Fixed code formatting inconsistencies and missing spaces

### Security Improvements  
- Added protection against malicious MQTT packets that could cause infinite loops
- Enhanced buffer boundary validation to prevent potential crashes
- Improved error handling for malformed network data

### Performance Improvements
- Optimized message processing loop to avoid unnecessary iterations
- Better memory management in buffer operations
- Reduced risk of memory leaks in singleton patterns

### Code Quality
- Eliminated circular dependencies between modules
- Improved code formatting and consistency
- Enhanced error messages for better debugging
- Added comprehensive safety checks throughout the codebase

## 1.0.5
- fixed some bug

## 1.0.4
- wildcards topic support

## 1.0.3
- update xtransport to support web platform

## 1.0.2+4
- update xtransport

## 1.0.2
- export buildContext to onReady
= export paused to interface

## 1.0.1+3
- update xtransport to new version

## 1.0.1+2
- change xtransport dep

## 1.0.1+1

- fix some bug
- add some todo

## 1.0.1

- chuck data supported
- unsubscribe qos and messageid fix

## 1.0.0

- Initial version.
