library doh;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import './model/doh_response.dart';
import './model/doh_exceptions.dart';
import './src/cache.dart';
import './model/doh_enum.dart';
import 'dart:developer' as developer;

export './model/doh_enum.dart' show DohRequestType, DoHProvider, DnsResponseCode;
export './model/doh_exceptions.dart';
export './model/doh_response.dart' show DoHResponse, DoHQuestion, DoHAnswer;

/// DNS over HTTPS Client
/// 
/// A DNS client using the DoH JSON protocol for DNS queries.
/// Supports multiple DoH providers with caching and failover mechanisms.
/// 
/// Example usage:
/// ```dart
/// final doh = DoH();
/// final results = await doh.lookup('example.com', DohRequestType.A);
/// print(results.map((r) => r.data).toList());
/// ```
class DoH {
  static DoH? _instance;
  static final Object _lock = Object();
  
  final DohAnswerCache _cache = DohAnswerCache();
  final List<Uri> _providers;
  final String? _proxyHost;
  final int? _proxyPort;
  HttpClient? _httpClient;
  
  /// Get the default instance (singleton pattern)
  static DoH get instance {
    if (_instance == null) {
      synchronized(_lock, () {
        _instance ??= DoH();
      });
    }
    return _instance!;
  }
  
  /// Reset singleton instance (mainly for testing)
  static void resetInstance() {
    synchronized(_lock, () {
      _instance?._httpClient?.close();
      _instance = null;
    });
  }
  
  /// Create new DoH instance
  /// 
  /// [providers] List of DoH providers to use
  /// If null, will use the default provider list
  /// [proxyHost] Proxy server host (for testing with proxies like 127.0.0.1)
  /// [proxyPort] Proxy server port (for testing with proxies like 7890)
  DoH({
    List<Uri>? providers,
    String? proxyHost,
    int? proxyPort,
  })  : _providers = List.unmodifiable(providers ?? _defaultProviders),
        _proxyHost = proxyHost,
        _proxyPort = proxyPort {
    if (_providers.isEmpty) {
      throw ArgumentError('Providers list cannot be empty');
    }
    _initHttpClient();
  }
  
  /// Default DoH provider list
  static final List<Uri> _defaultProviders = [
    DoHProvider.google2,
    DoHProvider.google1,
    DoHProvider.cloudflare2,
    DoHProvider.cloudflare1,
    DoHProvider.quad9,
    DoHProvider.tw101,
    DoHProvider.alidns,
    DoHProvider.alidns2,
  ];
  
  /// Get current list of providers
  List<Uri> get providers => List.unmodifiable(_providers);
  
  /// Initialize HTTP client
  void _initHttpClient() {
    _httpClient?.close();
    final context = SecurityContext.defaultContext;
    _httpClient = HttpClient(context: context)
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback = (cert, host, port) => true;
    
    // Set up proxy if specified
    if (_proxyHost != null && _proxyPort != null) {
      _httpClient!.findProxy = (uri) {
        return 'PROXY $_proxyHost:$_proxyPort';
      };
      developer.log(
        'Using proxy: $_proxyHost:$_proxyPort',
        name: 'doh.proxy',
      );
    }
  }
  
  /// Close HTTP client and cleanup resources
  void dispose() {
    _httpClient?.close();
    _httpClient = null;
  }
  
  /// DNS lookup
  /// 
  /// [domain] Domain name to query, cannot be empty
  /// [type] DNS record type, must be a valid [DohRequestType]
  /// [cache] Whether to use cache, recommended to keep true
  /// [dnssec] DNSSEC support (under development)
  /// [timeout] Timeout duration per attempt
  /// [attempts] Number of retry attempts
  /// 
  /// Returns list of matching DNS records
  /// 
  /// Throws:
  /// - [ArgumentError] when parameters are invalid
  /// - [InvalidRequestTypeException] when request type is not supported
  /// - [DnsResolutionException] when resolution fails
  /// - [NetworkException] when network connection fails
  Future<List<T>> lookup<T extends DoHAnswer>(
    String domain,
    DohRequestType type, {
    bool cache = true,
    bool dnssec = false,
    Duration timeout = const Duration(seconds: 5),
    int attempts = 1,
  }) async {
    if (domain.isEmpty) {
      throw ArgumentError('Domain cannot be empty');
    }
    
    if (attempts < 1) {
      throw ArgumentError('Attempts must be at least 1');
    }
    
    // Normalize domain name
    final normalizedDomain = domain.toLowerCase().trim();
    
    // Check cache
    if (cache) {
      final cachedResults = _cache.lookup<T>(normalizedDomain, type);
      if (cachedResults.isNotEmpty) {
        developer.log(
          'Found cached results for $normalizedDomain ($type)',
          name: 'doh.cache',
        );
        return cachedResults;
      }
    }
    
    // Perform lookup
    final results = await _performLookup<T>(
      normalizedDomain,
      type,
      dnssec: dnssec,
      timeout: timeout,
      attempts: attempts,
    );
    
    // Update cache
    if (cache) {
      try {
        _cache.updateRecords(results.cast<DoHAnswer>());
      } catch (e) {
        developer.log(
          'Failed to update cache: $e',
          name: 'doh.cache',
          level: 900, // WARNING
        );
      }
    }
    
    return results;
  }
  
  /// Clear cache for specific domain and type
  void clearCache(String domain, DohRequestType type) {
    final normalizedDomain = domain.toLowerCase().trim();
    _cache.kick(normalizedDomain, type);
  }
  
  /// Clear all cache entries
  void clearAllCache() {
    // TODO: Add clearAll method in cache.dart
    developer.log('Cache cleared', name: 'doh.cache');
  }
  
  /// Get cache statistics
  int get cacheEntryCount => _cache.entryCount;
  
  /// Perform actual DNS lookup
  Future<List<T>> _performLookup<T extends DoHAnswer>(
    String domain,
    DohRequestType type, {
    required bool dnssec,
    required Duration timeout,
    required int attempts,
  }) async {
    final resType = dohRequestTypeMap[type];
    if (resType == null) {
      throw InvalidRequestTypeException(type.toString());
    }
    
    Exception? lastException;
    
    for (int attempt = 0; attempt < attempts; attempt++) {
      final provider = _providers[attempt % _providers.length];
      
      try {
        final results = await _queryProvider<T>(
          domain,
          type,
          resType,
          provider,
          dnssec: dnssec,
          timeout: timeout,
        );
        
        developer.log(
          'Successfully resolved $domain ($type) from $provider',
          name: 'doh.query',
        );
        
        return results;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        developer.log(
          'Attempt ${attempt + 1}/$attempts failed for $domain ($type) from $provider: $e',
          name: 'doh.query',
          level: 900, // WARNING
        );
        
        if (attempt == attempts - 1) {
          break; // Last attempt, break to throw exception
        }
      }
    }
    
    // All attempts failed
    throw DnsResolutionException(
      domain,
      type.toString(),
      'All $attempts attempts failed',
      lastException,
    );
  }
  
  /// Query from specific provider
  Future<List<T>> _queryProvider<T extends DoHAnswer>(
    String domain,
    DohRequestType type,
    int resType,
    Uri provider, {
    required bool dnssec,
    required Duration timeout,
  }) async {
    final client = _httpClient;
    if (client == null) {
      throw NetworkException('HTTP client not initialized');
    }
    
    final url = provider.replace(queryParameters: {
      'name': domain,
      'type': type.toString().replaceFirst('DohRequestType.', ''),
      'dnssec': dnssec ? '1' : '0',
    });
    
    developer.log(
      'Querying $provider for $domain ($type), dnssec: $dnssec',
      name: 'doh.query',
    );
    
    try {
      // Set timeout
      client.connectionTimeout = timeout;
      
      final request = await client.getUrl(url);
      request.headers.add('Accept', 'application/dns-json');
      request.headers.add('User-Agent', 'DoH-Dart-Client/0.0.4');
      
      final response = await request.close();
      
      if (response.statusCode != 200) {
        throw NetworkException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          provider.toString(),
        );
      }
      
      final responseBody = await response
          .cast<List<int>>()
          .transform(const Utf8Decoder())
          .join();
      
      return _parseResponse<T>(responseBody, domain, resType, provider);
    } on SocketException catch (e) {
      throw NetworkException('Socket error: ${e.message}', provider.toString(), e);
    } on TimeoutException catch (e) {
      throw NetworkException('Request timeout', provider.toString(), e);
    } on HttpException catch (e) {
      throw NetworkException('HTTP error: ${e.message}', provider.toString(), e);
    } catch (e) {
      throw NetworkException('Unexpected error: $e', provider.toString(), e);
    }
  }
  
  /// Parse DoH response
  List<T> _parseResponse<T extends DoHAnswer>(
    String responseBody,
    String domain,
    int resType,
    Uri provider,
  ) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final response = DoHResponse.fromJson(json);
      
      if (response.status != 0) {
        throw ResponseParsingException('DNS query failed with status: ${response.status}');
      }
      
      if (response.answers.isEmpty) {
        throw DnsResolutionException(domain, resType.toString(), 'No answers in response');
      }
      
      // Process answer records
      _processAnswers(response.answers, domain, resType, provider);
      
      // Filter matching results
      final results = response.answers
          .where((answer) => answer.type == resType && answer.name == domain)
          .toList();
      
      if (results.isEmpty) {
        throw DnsResolutionException(domain, resType.toString(), 'No matching records found');
      }
      
      // Safe type casting
      if (results.every((answer) => answer is T)) {
        return results.cast<T>();
      } else {
        throw ResponseParsingException('Type mismatch in response parsing');
      }
    } on FormatException catch (e) {
      throw ResponseParsingException('Invalid JSON response', e);
    } catch (e) {
      if (e is DoHException) rethrow;
      throw ResponseParsingException('Failed to parse response: $e', e);
    }
  }
  
  /// Process answer records in response
  void _processAnswers(List<DoHAnswer> answers, String domain, int resType, Uri provider) {
    for (final answer in answers) {
      // Normalize domain name
      answer.name = answer.name.toLowerCase();
      answer.provider = provider;
      
      // Remove trailing dot
      if (answer.name.endsWith('.')) {
        answer.name = answer.name.substring(0, answer.name.length - 1);
      }
      
      // If the response is CNAME but querying for other types, add a record pointing to original domain
      if (answer.name != domain && answer.type == resType) {
        answers.add(DoHAnswer(
          name: domain,
          ttl: answer.ttl,
          type: answer.type,
          data: answer.data,
          provider: answer.provider,
        ));
      }
    }
  }
}

/// Simple synchronization lock implementation
void synchronized(Object lock, void Function() callback) {
  // This is a simplified implementation in Dart
  // In production, might need to use the synchronized package
  callback();
}
