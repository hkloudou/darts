## [0.0.4+2] - 2024-12-19

### 🇨🇳 China Network Optimization & Proxy Support

#### ✨ New Features
- **China Network Support**: Smart provider categorization for China mainland users
- **Proxy Support**: Added HTTP/SOCKS proxy support for blocked providers
- **Provider Classification**: 
  - `chinaDirectProviders` (3) - Direct access providers (Alibaba DNS, Taiwan DNS)
  - `chinaProxyProviders` (9) - Proxy-required providers (Google, Cloudflare, etc.)
  - `chinaOptimizedProviders` (12) - Smart fallback strategy
- **Smart Testing Script**: `test_proxy.dart` with automatic fallback strategy
- **Clash/V2Ray Integration**: Built-in support for popular proxy tools

#### 🔧 Provider Reorganization
- **Direct Access**: Alibaba DNS (alidns, alidns2), Taiwan DNS (tw101) 
- **Proxy Required**: Google DNS, Cloudflare, Quad9, OpenDNS, AdGuard, DNS.SB
- **Auto-Detection**: Smart switching between direct and proxy access
- **Performance Optimized**: Prioritize direct providers for lower latency

#### 📚 Documentation Updates
- **China Network Guide**: Comprehensive guide for China users
- **Proxy Configuration**: Examples for Clash, V2Ray, and other tools
- **Best Practices**: Recommended strategies for different environments
- **Testing Guide**: How to verify network connectivity

#### 🧪 Testing Improvements
- **Network-Aware Tests**: Separate tests for direct and proxy providers
- **Fallback Testing**: Automatic proxy port detection (7890, 1080, 8080, etc.)
- **Provider Validation**: Tests ensure proper categorization
- **Performance Monitoring**: Connection time measurement

#### 🛠 Code Cleanup
- **Redundant Code Removal**: Eliminated duplicate implementations
- **Test Optimization**: Streamlined testing logic and removed repetition
- **Provider Logic**: Simplified provider switching mechanism
- **Error Handling**: More descriptive error messages for China users

### 🎯 Usage for China Users

```dart
// Direct providers (fastest, no proxy needed)
final directClient = DoH(providers: DoHProvider.chinaDirectProviders);

// Proxy providers (for blocked services)
final proxyClient = DoH(
  providers: DoHProvider.chinaProxyProviders,
  proxyHost: '127.0.0.1',
  proxyPort: 7890, // Clash default port
);

// Smart combined approach (recommended)
final smartClient = DoH(providers: DoHProvider.chinaOptimizedProviders);
```

### 🧪 Testing Your Setup

```bash
# Run comprehensive network test
dart run test_proxy.dart
```

The test will:
1. Try direct providers first (no proxy)
2. Fall back to proxy providers with 127.0.0.1:7890
3. Test alternative proxy ports if needed
4. Provide detailed connectivity report

## [0.0.4+1] - 2024-12-19

### 🎉 Major Architecture Overhaul & Feature Enhancements

#### ✨ New Features
- **25+ DNS Record Types**: Added comprehensive support for DNS record types including DNSSEC records (DS, RRSIG, NSEC, DNSKEY, etc.)
- **12 DoH Providers**: Added support for AdGuard DNS, DNS.SB, OpenDNS, and more providers
- **Provider Groups**: Added `recommendedProviders`, `chinaOptimizedProviders`, and `allProviders` for easy selection
- **Advanced Caching**: Implemented LRU cache with memory management, statistics, and configurable limits
- **Custom Exception System**: Added detailed exception types (DnsResolutionException, NetworkException, etc.)
- **Cache Statistics**: Added hit rate, memory usage tracking, and cache entry counting
- **Resource Management**: Added proper `dispose()` method for cleanup

#### 🔧 Breaking Changes
- **Singleton Pattern**: Improved singleton implementation with proper lifecycle management
- **API Changes**: Modified `lookup()` method parameters (`attempt` → `attempts`)
- **Type Safety**: Enhanced generic type constraints and safe type casting
- **Provider Management**: Removed mutable `provider` setter, use constructor parameter instead

#### 🚀 Performance Improvements
- **HTTP Client Reuse**: Single HTTP client instance per DoH client to avoid connection overhead
- **Parallel Tool Execution**: Optimized for concurrent DNS queries
- **Memory Management**: Smart cache cleanup with TTL expiration and LRU eviction
- **Connection Pooling**: Reused connections for better performance

#### 🛠 Architecture Improvements
- **Error Handling**: Comprehensive error handling with specific exception types
- **Code Organization**: Better module separation and clear responsibilities
- **Type System**: Enhanced type safety with proper generic constraints
- **Validation**: Input validation for all public methods

#### 📚 Documentation & Examples
- **Complete README**: Professional documentation with usage examples
- **API Reference**: Detailed method documentation with parameter descriptions
- **Example Code**: Comprehensive examples demonstrating all features
- **Performance Guide**: Best practices for optimal performance

#### 🧪 Testing Improvements
- **Test Coverage**: Comprehensive test suite covering all major functionality
- **Error Testing**: Tests for all exception scenarios
- **Performance Tests**: Concurrent query and caching performance tests
- **Model Tests**: Unit tests for all data models

#### 🌐 Internationalization
- **English Documentation**: All comments and documentation converted to English
- **Consistent Naming**: Standardized naming conventions throughout codebase

#### 🔧 Technical Improvements
- **DNS Response Parsing**: Improved RFC 8484 compliance and error handling
- **Cache Algorithm**: Advanced LRU cache with memory pressure management
- **Network Stack**: Better timeout handling and connection management
- **Error Recovery**: Improved failover between providers

### 🏃‍♂️ Migration Guide

#### From 0.0.3 to 0.0.4
```dart
// Old way (deprecated)
DoH.instance.provider = [DoHProvider.cloudflare1];
await DoH.instance.lookup('example.com', DohRequestType.A, attempt: 2);

// New way
final doh = DoH(providers: [DoHProvider.cloudflare1]);
try {
  final results = await doh.lookup('example.com', DohRequestType.A, attempts: 2);
  // Process results
} finally {
  doh.dispose(); // Important: cleanup resources
}
```

#### Exception Handling
```dart
// Enhanced error handling
try {
  final results = await doh.lookup('example.com', DohRequestType.A);
} on DnsResolutionException catch (e) {
  print('DNS resolution failed: ${e.domain} - ${e.message}');
} on NetworkException catch (e) {
  print('Network error from ${e.provider}: ${e.message}');
} on InvalidRequestTypeException catch (e) {
  print('Unsupported record type: ${e.requestType}');
}
```

## [0.0.3+4] - 2024-12-18

### Added
- Basic DoH client functionality
- Support for multiple DNS providers
- Simple caching mechanism
- A, AAAA, CNAME, MX, NS, TXT record types

### Fixed
- Initial implementation bugs
- Provider failover issues

## [0.0.3+1] - 2024-12-17

### Added
- Initial release
- Basic DNS over HTTPS support
- Google, Cloudflare, and Alibaba DNS providers
