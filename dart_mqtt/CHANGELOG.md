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
