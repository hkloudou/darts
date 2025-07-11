# xtransport

A cross-platform network transport interface for Dart/Flutter that provides a simple way to manage network transport protocols like TCP, WebSocket, and more.

## ✨ Features

- 🌐 **Cross-platform support**: Works on mobile, web, and desktop
- 🔌 **Multiple protocols**: TCP, WebSocket (with both IO and HTML implementations)
- 🔒 **Security support**: TLS/SSL with custom certificates and validation
- 📱 **Platform-adaptive**: Automatically uses appropriate implementation for each platform
- 🎯 **Simple API**: Unified interface for all transport types
- 🔧 **Configurable**: Flexible credentials and connection options

## 📦 Installation

```sh
dart pub add xtransport
```

## 🚀 Quick Start

### TCP Connection
```dart
import 'package:xtransport/xtransport.dart';

// Create TCP client
var client = XTransportTcpClient.from("127.0.0.1", 8080);

// Set up event handlers
client.onConnect(() => print('Connected!'));
client.onMessage((msg) => print('Received: ${msg.message}'));
client.onError((err) => print('Error: ${err.errMsg}'));
client.onClose(() => print('Disconnected'));

// Connect
await client.connect();
```

### WebSocket Connection
```dart
import 'package:xtransport/xtransport.dart';

// Create WebSocket client
var client = XTransportWsClient.from("example.com", "/ws", 80);

// Set up handlers and connect
client.onConnect(() => print('WebSocket connected!'));
await client.connect();
```

### Secure Connection with TLS
```dart
var client = XTransportTcpClient.from(
  "secure.example.com", 
  443,
  credentials: XtransportCredentials.secure(
    authority: "secure.example.com",
    certificates: certificateBytes,
    onBadCertificate: (cert, host) => true, // Custom validation
  ),
);
```

## 📚 API Reference

### Core Classes
- `XTransportTcpClient` - TCP transport implementation
- `XTransportWsClient` - WebSocket transport (auto-selects IO/HTML)
- `XtransportCredentials` - Security and authentication configuration
- `Message` - Transport message container
- `XTransportError` - Error handling

### Events
- `onConnect()` - Connection established
- `onMessage(Message msg)` - Data received
- `onError(XTransportError err)` - Error occurred
- `onClose()` - Connection closed

## 🌍 Platform Support

| Platform | TCP | WebSocket | TLS/SSL |
|----------|-----|-----------|---------|
| Flutter Mobile | ✅ | ✅ | ✅ |
| Flutter Web | ❌ | ✅ | ✅ |
| Flutter Desktop | ✅ | ✅ | ✅ |
| Dart CLI | ✅ | ✅ | ✅ |

## 🔄 Other Language Implementations
- **Golang**: https://github.com/hkloudou/xtransport

## 🛠️ Development

```sh
# Install dependencies
dart pub get

# Run tests
dart run example/bin/simple_test.dart

# Format code
dart format ./

# Analyze
dart analyze
```

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed release notes.

## 📄 License

This project is licensed under the terms specified in [LICENSE](LICENSE).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.