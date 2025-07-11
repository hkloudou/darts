# DoH - DNS over HTTPS Client

[![Pub Version](https://img.shields.io/pub/v/doh)](https://pub.dev/packages/doh)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A high-performance, feature-rich DNS over HTTPS (DoH) client library with multiple providers, smart caching, and failover support, optimized specifically for China network environments.

## Features

✅ **Multiple Provider Support** - Built-in 12+ mainstream DoH providers including Google, Cloudflare, Alibaba, Quad9, etc.  
✅ **China Network Optimization** - Smart detection of China-accessible vs proxy-required providers with automatic switching  
✅ **Proxy Support** - HTTP/SOCKS proxy support, perfect integration with Clash, V2Ray and other proxy tools  
✅ **Smart Caching** - TTL-based intelligent caching with LRU cleanup strategy and memory management  
✅ **Failover Support** - Automatic switching between multiple providers to ensure successful queries  
✅ **Complete Record Types** - Support for 25+ DNS record types including A, AAAA, CNAME, MX, TXT, DNSSEC, etc.  
✅ **Performance Optimized** - Connection reuse, concurrent queries, intelligent timeout control  
✅ **Error Handling** - Detailed exception types and error messages  
✅ **Type Safety** - Complete Dart type definitions and parameter validation  

## Quick Start

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  doh: ^0.0.4+2
```

Then run:

```bash
dart pub get
```

### Basic Usage

```dart
import 'package:doh/doh.dart';

void main() async {
  // Create DoH client
  final doh = DoH();
  
  try {
    // Query A record
    final results = await doh.lookup('google.com', DohRequestType.A);
    
    for (final record in results) {
      print('${record.name} -> ${record.data} (TTL: ${record.remainingTtl}s)');
    }
  } finally {
    // Cleanup resources
    doh.dispose();
  }
}
```

## Detailed Usage

### Supported Record Types

```dart
// IPv4 address record
final ipv4 = await doh.lookup('example.com', DohRequestType.A);

// IPv6 address record
final ipv6 = await doh.lookup('example.com', DohRequestType.AAAA);

// Mail server record
final mail = await doh.lookup('example.com', DohRequestType.MX);

// Text record
final txt = await doh.lookup('example.com', DohRequestType.TXT);

// Name server record
final ns = await doh.lookup('example.com', DohRequestType.NS);
```

### Cache Control

```dart
// Enable cache (default)
final cached = await doh.lookup('example.com', DohRequestType.A, cache: true);

// Disable cache
final fresh = await doh.lookup('example.com', DohRequestType.A, cache: false);

// Clear specific cache
doh.clearCache('example.com', DohRequestType.A);

// View cache status
print('Cache entries: ${doh.cacheEntryCount}');
```

### Custom Providers

```dart
// Use specific provider
final customClient = DoH(providers: [DoHProvider.cloudflare1]);

// Use recommended providers (balanced performance and reliability)
final recommended = DoH(providers: DoHProvider.recommendedProviders);

// Use China optimized providers
final chinaOptimized = DoH(providers: DoHProvider.chinaOptimizedProviders);
```

## China Network Optimization 🇨🇳

This library is specifically optimized for China network environments, intelligently handling access strategies for different DoH providers.

### Provider Classification

#### Direct Access Providers (China accessible without proxy)
```dart
// These providers can be accessed directly in China, no proxy needed
final directProviders = DoHProvider.chinaDirectProviders;
// Includes: Alibaba DNS (alidns, alidns2), Taiwan DNS (tw101)
```

#### Proxy Required Providers (China requires proxy)
```dart
// These providers require proxy access in China
final proxyProviders = DoHProvider.chinaProxyProviders;
// Includes: Google DNS, Cloudflare, Quad9, OpenDNS, AdGuard, DNS.SB, etc.
```

### Proxy Configuration

#### Basic Proxy Setup
```dart
// Configure proxy for blocked providers
final dohWithProxy = DoH(
  providers: DoHProvider.chinaProxyProviders,
  proxyHost: '127.0.0.1',    // Clash/V2Ray proxy address
  proxyPort: 7890,           // Proxy port
);
```

#### Smart Dual-Stack Strategy (Recommended)
```dart
// Create direct client (for Alibaba DNS, etc.)
final directClient = DoH(providers: DoHProvider.chinaDirectProviders);

// Create proxy client (for Google, Cloudflare, etc.)
final proxyClient = DoH(
  providers: DoHProvider.chinaProxyProviders,
  proxyHost: '127.0.0.1',
  proxyPort: 7890,
);

// Try direct first, fallback to proxy
try {
  final results = await directClient.lookup('example.com', DohRequestType.A);
  // Use direct results
} catch (e) {
  final results = await proxyClient.lookup('example.com', DohRequestType.A);
  // Use proxy results
}
```

### Common Proxy Tool Configuration

#### Clash
```yaml
# Clash configuration example
port: 7890
socks-port: 7891
mixed-port: 7890
allow-lan: false
mode: global
log-level: info
```

```dart
// Using Clash proxy
final doh = DoH(
  providers: DoHProvider.chinaProxyProviders,
  proxyHost: '127.0.0.1',
  proxyPort: 7890,  // Clash default port
);
```

#### V2Ray/V2RayN
```dart
// Using V2Ray proxy
final doh = DoH(
  providers: DoHProvider.chinaProxyProviders,
  proxyHost: '127.0.0.1',
  proxyPort: 10808,  // V2Ray default port
);
```

### Network Connectivity Testing

Use the provided test script to verify network connectivity:

```bash
# Run network test
dart run test_proxy.dart
```

The test script will:
1. First test China-accessible providers without proxy
2. If that fails, automatically test proxy access
3. Try multiple common proxy ports
4. Provide detailed connectivity status report

### Best Practices

1. **Production Recommendation**: Use `DoHProvider.chinaOptimizedProviders` which includes both direct and proxy providers
2. **Development Testing**: Test both direct and proxy providers separately to ensure dual-stack availability
3. **Performance Optimization**: Prioritize Alibaba DNS and other direct providers to reduce latency
4. **Fault Tolerance**: Implement automatic switching mechanism, enable proxy when direct access fails

### Timeout and Retry

```dart
final results = await doh.lookup(
  'example.com',
  DohRequestType.A,
  timeout: Duration(seconds: 10),  // 10 second timeout
  attempts: 3,                     // Retry 3 times
);
```

### Error Handling

```dart
try {
  final results = await doh.lookup('example.com', DohRequestType.A);
  print('Query successful: ${results.length} records');
} on DnsResolutionException catch (e) {
  print('DNS resolution failed: ${e.domain} - ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.provider} - ${e.message}');
} on InvalidRequestTypeException catch (e) {
  print('Unsupported record type: ${e.requestType}');
} catch (e) {
  print('Unknown error: $e');
}
```

### Concurrent Queries

```dart
final domains = ['google.com', 'github.com', 'stackoverflow.com'];

// Concurrent queries for better performance
final futures = domains.map((domain) => 
    doh.lookup(domain, DohRequestType.A));

final results = await Future.wait(futures);

for (int i = 0; i < domains.length; i++) {
  final ips = results[i].map((r) => r.data).join(', ');
  print('${domains[i]}: $ips');
}
```

## Available DoH Providers

| Provider | Description | China Access | Region Optimization |
|----------|-------------|--------------|-------------------|
| `DoHProvider.alidns/2` | Alibaba Public DNS | ✅ Direct | China Mainland |
| `DoHProvider.tw101` | Taiwan Network Information Center | ✅ Direct | Asia Pacific |
| `DoHProvider.google1/2` | Google Public DNS | 🔧 Proxy Required | Global |
| `DoHProvider.cloudflare1/2` | Cloudflare DNS | 🔧 Proxy Required | Global |
| `DoHProvider.quad9` | Quad9 DNS (Malware Protection) | 🔧 Proxy Required | Global |
| `DoHProvider.opendns1/2` | OpenDNS | 🔧 Proxy Required | Global |
| `DoHProvider.adguard` | AdGuard DNS (Ad Blocking) | 🔧 Proxy Required | Global |
| `DoHProvider.dnssb` | DNS.SB | 🔧 Proxy Required | Global |

### Provider Groups

- `DoHProvider.chinaDirectProviders` - China Direct Access (3 providers)
- `DoHProvider.chinaProxyProviders` - China Proxy Required (9 providers)  
- `DoHProvider.chinaOptimizedProviders` - China Optimized (all 12 providers)
- `DoHProvider.recommendedProviders` - Recommended Providers (4 providers)
- `DoHProvider.allProviders` - All Providers (12 providers)

## Supported DNS Record Types

### Common Record Types
- **A** - IPv4 address record
- **AAAA** - IPv6 address record  
- **CNAME** - Canonical name record
- **MX** - Mail exchange record
- **NS** - Name server record
- **TXT** - Text record
- **SRV** - Service record

### DNSSEC Record Types
- **DS** - Delegation signer record
- **RRSIG** - Resource record signature
- **NSEC/NSEC3** - Next secure record
- **DNSKEY** - DNS key record

### Other Record Types
- **SOA** - Start of authority record
- **PTR** - Pointer record (reverse DNS)
- **CAA** - Certificate authority authorization record
- **TLSA** - Transport layer security association record

## API Reference

### DoH Class

#### Constructor
```dart
DoH({
  List<Uri>? providers,
  String? proxyHost,
  int? proxyPort,
})
```

#### Main Methods
```dart
// DNS query
Future<List<T>> lookup<T extends DoHAnswer>(
  String domain,
  DohRequestType type, {
  bool cache = true,
  bool dnssec = false,
  Duration timeout = const Duration(seconds: 5),
  int attempts = 1,
});

// Cache management
void clearCache(String domain, DohRequestType type);
int get cacheEntryCount;

// Resource cleanup
void dispose();
```

### Exception Types

- `DnsResolutionException` - DNS resolution failed
- `NetworkException` - Network connection error
- `InvalidRequestTypeException` - Unsupported record type
- `ResponseParsingException` - Response parsing error

## Performance Recommendations

1. **Reuse Client Instances** - Avoid frequently creating new DoH instances
2. **Enable Caching** - Utilize smart caching to reduce network requests
3. **Concurrent Queries** - Use `Future.wait()` for multiple domain queries
4. **Choose Appropriate Providers** - Select optimal providers based on geographic location
5. **Set Reasonable Timeouts** - Balance response speed and success rate

## Contributing

Issues and Pull Requests are welcome!

## License

MIT License. See [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version update information.
