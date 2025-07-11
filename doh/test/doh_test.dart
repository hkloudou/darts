import 'dart:convert';
import 'package:doh/doh.dart';
import 'package:test/test.dart';

void main() {
  group('DoH Tests', () {
    late DoH dohClient;

    setUp(() {
      // Create new client instance for each test
      dohClient = DoH();
    });

    tearDown(() {
      // Cleanup resources
      dohClient.dispose();
    });

    group('Basic DNS Resolution', () {
      test('should resolve A record for valid domain', () async {
        final results = await dohClient.lookup('google.com', DohRequestType.A);
        
        expect(results, isNotEmpty);
        expect(results.first.type, equals(1)); // A record type
        expect(results.first.data, matches(RegExp(r'^\d+\.\d+\.\d+\.\d+$'))); // IPv4 format
        print('A record for google.com: ${results.map((r) => r.data).toList()}');
      });

      test('should resolve AAAA record for valid domain', () async {
        final results = await dohClient.lookup('google.com', DohRequestType.AAAA);
        
        expect(results, isNotEmpty);
        expect(results.first.type, equals(28)); // AAAA record type
        expect(results.first.data, contains(':')); // IPv6 format contains colons
        print('AAAA record for google.com: ${results.map((r) => r.data).toList()}');
      });

      test('should resolve TXT record for valid domain', () async {
        final results = await dohClient.lookup('google.com', DohRequestType.TXT);
        
        expect(results, isNotEmpty);
        expect(results.first.type, equals(16)); // TXT record type
        print('TXT record for google.com: ${results.map((r) => r.data).toList()}');
      });

      test('should resolve MX record for valid domain', () async {
        final results = await dohClient.lookup('google.com', DohRequestType.MX);
        
        expect(results, isNotEmpty);
        expect(results.first.type, equals(15)); // MX record type
        print('MX record for google.com: ${results.map((r) => r.data).toList()}');
      });
    });

    group('Cache Functionality', () {
      test('should use cache on second request', () async {
        const domain = 'example.com';
        const type = DohRequestType.A;

        // First request
        final stopwatch1 = Stopwatch()..start();
        final results1 = await dohClient.lookup(domain, type);
        stopwatch1.stop();

        // Second request (should use cache)
        final stopwatch2 = Stopwatch()..start();
        final results2 = await dohClient.lookup(domain, type);
        stopwatch2.stop();

        expect(results1, isNotEmpty);
        expect(results2, isNotEmpty);
        expect(results1.length, equals(results2.length));
        expect(results1.first.data, equals(results2.first.data));
        
        // Cached request should be significantly faster
        expect(stopwatch2.elapsedMilliseconds, lessThan(stopwatch1.elapsedMilliseconds));
        
        print('First request: ${stopwatch1.elapsedMilliseconds}ms');
        print('Cached request: ${stopwatch2.elapsedMilliseconds}ms');
        print('Cache entries: ${dohClient.cacheEntryCount}');
      });

      test('should bypass cache when disabled', () async {
        const domain = 'example.com';
        const type = DohRequestType.A;

        // Requests with cache disabled
        final results1 = await dohClient.lookup(domain, type, cache: false);
        final results2 = await dohClient.lookup(domain, type, cache: false);

        expect(results1, isNotEmpty);
        expect(results2, isNotEmpty);
        expect(dohClient.cacheEntryCount, equals(0)); // Should have no cache entries
      });

      test('should clear specific cache entry', () async {
        const domain = 'example.com';
        const type = DohRequestType.A;

        // First request and cache
        await dohClient.lookup(domain, type);
        expect(dohClient.cacheEntryCount, greaterThan(0));

        // Clear specific cache
        dohClient.clearCache(domain, type);
        
        // Next request should re-resolve
        final stopwatch = Stopwatch()..start();
        await dohClient.lookup(domain, type);
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, greaterThan(10)); // Not a cached fast response
      });
    });

    group('Error Handling', () {
      test('should throw DnsResolutionException for non-existent domain', () async {
        expect(
          () => dohClient.lookup('this-domain-definitely-does-not-exist-12345.com', DohRequestType.A),
          throwsA(isA<DnsResolutionException>()),
        );
      });

      test('should throw ArgumentError for empty domain', () async {
        expect(
          () => dohClient.lookup('', DohRequestType.A),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for invalid attempts', () async {
        expect(
          () => dohClient.lookup('google.com', DohRequestType.A, attempts: 0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle timeout gracefully', () async {
        expect(
          () => dohClient.lookup(
            'google.com', 
            DohRequestType.A, 
            timeout: Duration(milliseconds: 1), // Very short timeout
            attempts: 1,
          ),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('Provider Management', () {
      test('should use custom providers', () async {
        final customClient = DoH(providers: [DoHProvider.cloudflare1]);
        
        final results = await customClient.lookup('google.com', DohRequestType.A);
        expect(results, isNotEmpty);
        expect(results.first.provider, equals(DoHProvider.cloudflare1));
        
        customClient.dispose();
      });

      test('should throw error for empty provider list', () {
        expect(() => DoH(providers: []), throwsA(isA<ArgumentError>()));
      });

      test('should cycle through providers on failure', () async {
        // This test needs provider failure simulation, may need more complex setup in actual testing
        final results = await dohClient.lookup('google.com', DohRequestType.A, attempts: 3);
        expect(results, isNotEmpty);
      });
    });

    group('Record Types', () {
      test('should support all common record types', () async {
        const domain = 'google.com';
        
        for (final type in DohRequestType.commonTypes) {
          try {
            final results = await dohClient.lookup(domain, type);
            print('${type.name} records for $domain: ${results.length} found');
            
            if (results.isNotEmpty) {
              expect(results.first.type, equals(type.value));
              expect(results.first.typeName, equals(type.name));
            }
          } catch (e) {
            // Some record types may not exist, which is normal
            if (e is! DnsResolutionException) {
              rethrow;
            }
          }
        }
      });

      test('should validate record type enum', () {
        // Test enum functionality
        expect(DohRequestType.fromName('A'), equals(DohRequestType.A));
        expect(DohRequestType.fromName('AAAA'), equals(DohRequestType.AAAA));
        expect(DohRequestType.fromName('INVALID'), isNull);
        
        expect(DohRequestType.fromValue(1), equals(DohRequestType.A));
        expect(DohRequestType.fromValue(28), equals(DohRequestType.AAAA));
        expect(DohRequestType.fromValue(99999), isNull);
      });
    });

    group('Response Validation', () {
      test('should validate DoH response structure', () async {
        final results = await dohClient.lookup('google.com', DohRequestType.A);
        
        expect(results, isNotEmpty);
        
        for (final result in results) {
          expect(result.name, isNotEmpty);
          expect(result.type, greaterThan(0));
          expect(result.data, isNotEmpty);
          expect(result.ttl, greaterThan(0));
          expect(result.isValid, isTrue);
          expect(result.isExpired, isFalse);
          expect(result.remainingTtl, greaterThan(0));
        }
      });

      test('should handle case insensitive domain names', () async {
        final results1 = await dohClient.lookup('GOOGLE.COM', DohRequestType.A, cache: false);
        final results2 = await dohClient.lookup('google.com', DohRequestType.A, cache: false);
        
        expect(results1, isNotEmpty);
        expect(results2, isNotEmpty);
        expect(results1.first.name.toLowerCase(), equals(results2.first.name.toLowerCase()));
      });
    });

    group('Performance Tests', () {
      test('should handle concurrent requests', () async {
        const domains = ['google.com', 'github.com', 'stackoverflow.com'];
        
        final futures = domains.map(
          (domain) => dohClient.lookup(domain, DohRequestType.A)
        ).toList();
        
        final results = await Future.wait(futures);
        
        expect(results, hasLength(domains.length));
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotEmpty);
          print('${domains[i]}: ${results[i].map((r) => r.data).toList()}');
        }
      });

      test('should handle multiple record types for same domain', () async {
        const domain = 'google.com';
        final types = [DohRequestType.A, DohRequestType.AAAA, DohRequestType.MX];
        
        final futures = types.map(
          (type) => dohClient.lookup(domain, type)
        ).toList();
        
        final results = await Future.wait(futures);
        
        for (int i = 0; i < results.length; i++) {
          if (results[i].isNotEmpty) {
            expect(results[i].first.type, equals(types[i].value));
            print('${types[i].name} for $domain: ${results[i].length} records');
          }
        }
      });
    });
  });

  group('DoH Models Tests', () {
    group('DoHAnswer', () {
      test('should create valid DoHAnswer', () {
        final answer = DoHAnswer(
          name: 'example.com',
          ttl: 300,
          type: 1,
          data: '192.168.1.1',
        );

        expect(answer.name, equals('example.com'));
        expect(answer.ttl, equals(300));
        expect(answer.type, equals(1));
        expect(answer.data, equals('192.168.1.1'));
        expect(answer.typeName, equals('A'));
        expect(answer.isValid, isTrue);
        expect(answer.isExpired, isFalse);
        expect(answer.remainingTtl, lessThanOrEqualTo(300));
      });

      test('should handle expiration correctly', () async {
        final answer = DoHAnswer(
          name: 'example.com',
          ttl: 1, // 1 second TTL
          type: 1,
          data: '192.168.1.1',
        );

        expect(answer.isExpired, isFalse);
        
        // Wait more than TTL
        await Future.delayed(Duration(seconds: 2));
        
        expect(answer.isExpired, isTrue);
        expect(answer.remainingTtl, equals(0));
      });

      test('should match queries correctly', () {
        final answer = DoHAnswer(
          name: 'example.com',
          ttl: 300,
          type: 1,
          data: '192.168.1.1',
        );

        expect(answer.matches('example.com', 1), isTrue);
        expect(answer.matches('EXAMPLE.COM', 1), isTrue); // Case insensitive
        expect(answer.matches('example.com', 28), isFalse); // Different type
        expect(answer.matches('other.com', 1), isFalse); // Different name
      });
    });

    group('DoHResponse', () {
      test('should parse valid JSON response', () {
        final jsonResponse = {
          'Status': 0,
          'TC': false,
          'RD': true,
          'RA': true,
          'AD': false,
          'CD': false,
          'Question': [
            {'name': 'example.com', 'type': 1, 'class': 1}
          ],
          'Answer': [
            {
              'name': 'example.com',
              'type': 1,
              'TTL': 300,
              'data': '192.168.1.1'
            }
          ]
        };

        final response = DoHResponse.fromJson(jsonResponse);

        expect(response.status, equals(0));
        expect(response.isSuccessful, isTrue);
        expect(response.hasAnswers, isTrue);
        expect(response.question.name, equals('example.com'));
        expect(response.answers, hasLength(1));
        expect(response.answers.first.data, equals('192.168.1.1'));
      });

      test('should handle empty answers', () {
        final jsonResponse = {
          'Status': 3, // NXDOMAIN
          'Question': [
            {'name': 'nonexistent.example', 'type': 1}
          ],
          'Answer': []
        };

        final response = DoHResponse.fromJson(jsonResponse);

        expect(response.status, equals(3));
        expect(response.isSuccessful, isFalse);
        expect(response.hasAnswers, isFalse);
        expect(response.statusDescription, contains('Name error'));
      });
    });
  });

  group('Provider Tests', () {
    test('should have valid provider URIs', () {
      for (final provider in DoHProvider.allProviders) {
        expect(provider.scheme, anyOf('http', 'https'));
        expect(provider.host, isNotEmpty);
        print('Provider: $provider');
      }
    });

    test('should have recommended providers', () {
      final recommended = DoHProvider.recommendedProviders;
      expect(recommended, isNotEmpty);
      expect(recommended.length, lessThanOrEqualTo(DoHProvider.allProviders.length));
    });

    test('should have China optimized providers', () {
      final chinaOptimized = DoHProvider.chinaOptimizedProviders;
      expect(chinaOptimized, isNotEmpty);
      expect(chinaOptimized, contains(DoHProvider.alidns));
    });

    test('should have China direct access providers', () {
      final chinaDirect = DoHProvider.chinaDirectProviders;
      expect(chinaDirect, isNotEmpty);
      expect(chinaDirect, contains(DoHProvider.alidns));
      expect(chinaDirect, contains(DoHProvider.alidns2));
      expect(chinaDirect, contains(DoHProvider.tw101));
      
      // These should NOT be in direct providers (require proxy in China)
      expect(chinaDirect, isNot(contains(DoHProvider.google1)));
      expect(chinaDirect, isNot(contains(DoHProvider.cloudflare1)));
    });

    test('should have China proxy-required providers', () {
      final chinaProxy = DoHProvider.chinaProxyProviders;
      expect(chinaProxy, isNotEmpty);
      expect(chinaProxy, contains(DoHProvider.google1));
      expect(chinaProxy, contains(DoHProvider.google2));
      expect(chinaProxy, contains(DoHProvider.cloudflare1));
      expect(chinaProxy, contains(DoHProvider.cloudflare2));
      expect(chinaProxy, contains(DoHProvider.quad9));
      
      // These should NOT be in proxy providers (accessible directly in China)
      expect(chinaProxy, isNot(contains(DoHProvider.alidns)));
      expect(chinaProxy, isNot(contains(DoHProvider.alidns2)));
    });

    test('should have proper provider categorization', () {
      final all = DoHProvider.allProviders;
      final direct = DoHProvider.chinaDirectProviders;
      final proxy = DoHProvider.chinaProxyProviders;
      final optimized = DoHProvider.chinaOptimizedProviders;
      
      // No overlap between direct and proxy
      final overlap = direct.where((provider) => proxy.contains(provider));
      expect(overlap, isEmpty);
      
      // Optimized should contain both direct and proxy
      expect(optimized.length, equals(direct.length + proxy.length));
      
      // All providers should be covered
      expect(direct.length + proxy.length, equals(all.length));
    });
  });
}
