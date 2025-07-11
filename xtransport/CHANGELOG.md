## 0.0.6
* fix critical naming conflict: renamed `Error` class to `XTransportError` to avoid collision with Dart's built-in Error class
* fix TCP client assertion: changed from incorrect `tls://` protocol to correct `tcp://` protocol
* fix JSON serialization bugs: improved `Message.fromJson`, `RemoteInfo.fromJson`, and `LocalInfo.fromJson` logic
* fix WebSocket HTML implementation: corrected `send()` method to use `sendTypedData()` for proper binary data transmission
* fix error handling consistency: restored missing `_onClose?.call()` in error scenarios across all transport implementations
* improve API exports: added `jsons.dart` export to main library for better public API access
* add comprehensive test coverage for all bug fixes

## 0.0.5
* add web platform support

## 0.0.4+7
* add the websockets support

## 0.0.4+4
* fix the bug tcp timeout

## 0.0.4+3
* fix the bug tcp timeout

## 0.0.4+2
* move to hkloudou/darts

## 0.0.4+1
* remove wrong method flush.(fix some bug)

## 0.0.4
* update credentials interface

## 0.0.3
* lint some coce, and remove some unuse field


## 0.0.2
* lint some coce, and remove some unuse field


## 0.0.1
* TODO: Describe initial release.
