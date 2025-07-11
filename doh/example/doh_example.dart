import 'dart:convert';
import 'package:doh/doh.dart';

/// DNS over HTTPS client usage examples
/// 
/// Demonstrates how to use the DoH library for various DNS query operations
void main() async {
  print('=== DoH Client Examples ===\n');

  // Create client with default configuration
  final doh = DoH();

  try {
    // 1. Basic A record query
    await demonstrateBasicQuery(doh);

    // 2. Different record type queries
    await demonstrateRecordTypes(doh);

    // 3. Cache functionality demonstration
    await demonstrateCaching(doh);

    // 4. Error handling demonstration
    await demonstrateErrorHandling(doh);

    // 5. Custom provider demonstration
    await demonstrateCustomProviders();

    // 6. Concurrent query demonstration
    await demonstrateConcurrentQueries(doh);

  } finally {
    // Cleanup resources
    doh.dispose();
  }

  print('\n=== Examples Completed ===');
}

/// Demonstrate basic DNS query
Future<void> demonstrateBasicQuery(DoH doh) async {
  print('1. Basic A Record Query:');
  
  final domain = 'www.google.com';
  final results = await doh.lookup(domain, DohRequestType.A);
  
  print('  Domain: $domain');
  print('  A Records: ${results.map((r) => r.data).join(', ')}');
  print('  TTL: ${results.first.remainingTtl} seconds');
  print('  Provider: ${results.first.provider}');
  print('');
}

/// Demonstrate different DNS record type queries
Future<void> demonstrateRecordTypes(DoH doh) async {
  print('2. Different Record Type Queries:');
  
  const domain = 'google.com';
  final recordTypes = [
    DohRequestType.A,
    DohRequestType.AAAA,
    DohRequestType.MX,
    DohRequestType.TXT,
    DohRequestType.NS,
  ];

  for (final type in recordTypes) {
    try {
      final results = await doh.lookup(domain, type);
      if (results.isNotEmpty) {
        print('  ${type.name} Records: ${results.length} found');
        print('    Example: ${results.first.data}');
      } else {
        print('  ${type.name} Records: No records');
      }
    } catch (e) {
      print('  ${type.name} Records: Query failed ($e)');
    }
  }
  print('');
}

/// Demonstrate cache functionality
Future<void> demonstrateCaching(DoH doh) async {
  print('3. Cache Functionality Demo:');
  
  const domain = 'example.com';
  
  // First query (fetch from network)
  final stopwatch1 = Stopwatch()..start();
  final results1 = await doh.lookup(domain, DohRequestType.A);
  stopwatch1.stop();
  
  // Second query (fetch from cache)
  final stopwatch2 = Stopwatch()..start();
  final results2 = await doh.lookup(domain, DohRequestType.A);
  stopwatch2.stop();
  
  print('  First query: ${stopwatch1.elapsedMilliseconds}ms (network)');
  print('  Second query: ${stopwatch2.elapsedMilliseconds}ms (cache)');
  print('  Cache entries: ${doh.cacheEntryCount}');
  print('  Results match: ${results1.first.data == results2.first.data}');
  
  // Clear cache
  doh.clearCache(domain, DohRequestType.A);
  print('  Cache cleared');
  print('');
}

/// Demonstrate error handling
Future<void> demonstrateErrorHandling(DoH doh) async {
  print('4. Error Handling Demo:');
  
  try {
    // Query non-existent domain
    await doh.lookup('this-domain-does-not-exist-123456.invalid', DohRequestType.A);
  } catch (e) {
    print('  Non-existent domain: ${e.runtimeType} - ${e.toString().split(':').first}');
  }
  
  try {
    // Empty domain
    await doh.lookup('', DohRequestType.A);
  } catch (e) {
    print('  Empty domain: ${e.runtimeType} - Parameter validation failed');
  }
  
  try {
    // Timeout test
    await doh.lookup('google.com', DohRequestType.A, 
        timeout: Duration(milliseconds: 1), attempts: 1);
  } catch (e) {
    print('  Timeout test: ${e.runtimeType} - Network timeout');
  }
  print('');
}

/// Demonstrate custom providers
Future<void> demonstrateCustomProviders() async {
  print('5. Custom Provider Demo:');
  
  // Use Cloudflare provider
  final cloudflareClient = DoH(providers: [DoHProvider.cloudflare1]);
  
  try {
    final results = await cloudflareClient.lookup('www.github.com', DohRequestType.A);
    print('  Cloudflare provider: ${results.first.data}');
    print('  Provider: ${results.first.provider}');
  } finally {
    cloudflareClient.dispose();
  }
  
  // Use China optimized providers
  final chinaClient = DoH(providers: DoHProvider.chinaOptimizedProviders);
  
  try {
    final results = await chinaClient.lookup('www.baidu.com', DohRequestType.A);
    print('  China optimized provider: ${results.first.data}');
    print('  Provider: ${results.first.provider}');
  } finally {
    chinaClient.dispose();
  }
  print('');
}

/// Demonstrate concurrent queries
Future<void> demonstrateConcurrentQueries(DoH doh) async {
  print('6. Concurrent Query Demo:');
  
  final domains = ['google.com', 'github.com', 'stackoverflow.com', 'reddit.com'];
  final stopwatch = Stopwatch()..start();
  
  // Concurrent query for multiple domains
  final futures = domains.map((domain) => 
      doh.lookup(domain, DohRequestType.A).then((results) => {
        'domain': domain,
        'ip': results.isNotEmpty ? results.first.data : 'N/A',
        'count': results.length,
      })
  );
  
  final results = await Future.wait(futures);
  stopwatch.stop();
  
  print('  Concurrent query for ${domains.length} domains took: ${stopwatch.elapsedMilliseconds}ms');
  for (final result in results) {
    print('  ${result['domain']}: ${result['ip']} (${result['count']} records)');
  }
  print('');
}

/// Display detailed query results
void printDetailedResults(String domain, List<DoHAnswer> results) {
  print('Detailed Query Results:');
  print('  Domain: $domain');
  print('  Record count: ${results.length}');
  
  for (int i = 0; i < results.length; i++) {
    final record = results[i];
    print('  Record ${i + 1}:');
    print('    Type: ${record.typeName} (${record.type})');
    print('    Data: ${record.data}');
    print('    TTL: ${record.remainingTtl} seconds');
    print('    Valid: ${record.isValid ? 'Yes' : 'No'}');
    print('    Expired: ${record.isExpired ? 'Yes' : 'No'}');
    if (record.provider != null) {
      print('    Provider: ${record.provider}');
    }
  }
}
