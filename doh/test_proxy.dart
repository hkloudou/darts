import 'dart:io';
import 'package:doh/doh.dart';

/// Test script for DoH with proxy support
/// 
/// This script tests the DoH functionality with smart fallback strategy:
/// 1. First try China-accessible providers without proxy
/// 2. If that fails, try proxy-required providers with proxy (127.0.0.1:7890)
/// 3. Test different proxy ports if needed
void main() async {
  print('=== DoH China Network Testing ===\n');

  // First try China direct providers (no proxy needed)
  print('1. Testing China-accessible providers (direct connection)...');
  var success = await testDirectProviders();
  
  if (!success) {
    print('\n2. Direct providers failed, testing proxy-required providers...');
    success = await testProxyProviders(
      proxyHost: '127.0.0.1', 
      proxyPort: 7890,
    );
  }
  
  if (!success) {
    print('\n3. Default proxy failed, trying alternative proxy ports...');
    final commonPorts = [7890, 1080, 8080, 3128, 10808, 8118];
    
    for (final port in commonPorts) {
      print('   Trying proxy 127.0.0.1:$port...');
      success = await testProxyProviders(
        proxyHost: '127.0.0.1', 
        proxyPort: port,
      );
      if (success) break;
    }
  }
  
  if (success) {
    print('\n✅ DoH functionality test completed successfully!');
    print('📝 Use the working configuration in your DoH client for optimal performance.');
  } else {
    print('\n❌ All connection attempts failed.');
    print('💡 Please check:');
    print('   - Your network connection');
    print('   - Proxy settings (ensure Clash/v2ray is running on 127.0.0.1:7890)');
    print('   - Firewall configuration');
    exit(1);
  }
}

/// Test China direct accessible providers (no proxy required)
Future<bool> testDirectProviders() async {
  DoH? doh;
  
  try {
    print('   Using China direct providers: ${DoHProvider.chinaDirectProviders.length} providers');
    
    // Create DoH client with only direct providers
    doh = DoH(providers: DoHProvider.chinaDirectProviders);
    
    // Test basic functionality
    await _testBasicResolution(doh, 'China direct');
    await _testMultipleRecordTypes(doh);
    await _testCaching(doh);
    
    return true;
    
  } catch (e) {
    print('   ❌ Direct providers failed: $e');
    return false;
  } finally {
    doh?.dispose();
  }
}

/// Test providers that require proxy access in China
Future<bool> testProxyProviders({required String proxyHost, required int proxyPort}) async {
  DoH? doh;
  
  try {
    print('   Using proxy: $proxyHost:$proxyPort');
    print('   Testing proxy-required providers: ${DoHProvider.chinaProxyProviders.length} providers');
    
    // Create DoH client with proxy for blocked providers
    doh = DoH(
      providers: DoHProvider.chinaProxyProviders,
      proxyHost: proxyHost,
      proxyPort: proxyPort,
    );
    
    // Test basic functionality
    await _testBasicResolution(doh, 'Proxy');
    await _testMultipleRecordTypes(doh);
    await _testCaching(doh);
    
    return true;
    
  } catch (e) {
    print('   ❌ Proxy providers failed: $e');
    return false;
  } finally {
    doh?.dispose();
  }
}

/// Test basic A record resolution
Future<void> _testBasicResolution(DoH doh, String testName) async {
  print('   Testing basic A record resolution ($testName)...');
  
  final domains = ['google.com', 'cloudflare.com', 'github.com'];
  
  for (final domain in domains) {
    try {
      final results = await doh.lookup(domain, DohRequestType.A, attempts: 2);
      if (results.isNotEmpty) {
        print('     ✓ $domain -> ${results.first.data}');
        return; // Success, no need to test more domains
      }
    } catch (e) {
      print('     ✗ $domain failed: $e');
    }
  }
  
  throw Exception('All test domains failed resolution');
}

/// Test multiple record types
Future<void> _testMultipleRecordTypes(DoH doh) async {
  print('   Testing multiple record types...');
  
  final tests = [
    _TestCase('google.com', DohRequestType.A, 'IPv4'),
    _TestCase('google.com', DohRequestType.AAAA, 'IPv6'),
    _TestCase('google.com', DohRequestType.MX, 'Mail'),
    _TestCase('google.com', DohRequestType.TXT, 'Text'),
  ];
  
  for (final test in tests) {
    try {
      final results = await doh.lookup(test.domain, test.type, attempts: 1);
      if (results.isNotEmpty) {
        print('     ✓ ${test.name} (${test.type.name}): ${results.length} records');
      } else {
        print('     - ${test.name} (${test.type.name}): No records');
      }
    } catch (e) {
      print('     ✗ ${test.name} (${test.type.name}): Failed');
    }
  }
}

class _TestCase {
  final String domain;
  final DohRequestType type;
  final String name;
  
  const _TestCase(this.domain, this.type, this.name);
}

/// Test caching functionality
Future<void> _testCaching(DoH doh) async {
  print('   Testing cache functionality...');
  
  const domain = 'example.com';
  const type = DohRequestType.A;
  
  try {
    // First request (network)
    final stopwatch1 = Stopwatch()..start();
    final results1 = await doh.lookup(domain, type, attempts: 1);
    stopwatch1.stop();
    
    // Second request (cache)
    final stopwatch2 = Stopwatch()..start();
    final results2 = await doh.lookup(domain, type, attempts: 1);
    stopwatch2.stop();
    
    if (results1.isNotEmpty && results2.isNotEmpty) {
      print('     ✓ Cache working: ${stopwatch1.elapsedMilliseconds}ms -> ${stopwatch2.elapsedMilliseconds}ms');
      print('     ✓ Cache entries: ${doh.cacheEntryCount}');
    }
  } catch (e) {
    print('     ✗ Cache test failed: $e');
  }
}

/// Test provider diversity and error handling
Future<void> _testProviderDiversity(DoH doh) async {
  print('   Testing provider diversity...');
  
  final testDomains = ['google.com', 'cloudflare.com', 'example.com'];
  final providers = <Uri>{};
  
  for (final domain in testDomains) {
    try {
      final results = await doh.lookup(domain, DohRequestType.A, 
          cache: false, attempts: 1);
      if (results.isNotEmpty && results.first.provider != null) {
        providers.add(results.first.provider!);
      }
    } catch (e) {
      // Continue with next domain
    }
  }
  
  print('     ✓ Used ${providers.length} different providers');
  if (providers.isNotEmpty) {
    for (final provider in providers.take(3)) { // Show max 3 providers
      print('       - ${provider.host}');
    }
  }
} 