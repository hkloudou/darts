/// DNS over HTTPS related exception classes

/// Base DoH exception
abstract class DoHException implements Exception {
  final String message;
  final dynamic originalError;
  
  const DoHException(this.message, [this.originalError]);
  
  @override
  String toString() => 'DoHException: $message';
}

/// DNS resolution failure exception
class DnsResolutionException extends DoHException {
  final String domain;
  final String type;
  
  const DnsResolutionException(
    this.domain, 
    this.type, 
    String message, 
    [dynamic originalError]
  ) : super(message, originalError);
  
  @override
  String toString() => 'DnsResolutionException: Failed to resolve $domain ($type): $message';
}

/// Network connection exception
class NetworkException extends DoHException {
  final String? provider;
  
  const NetworkException(String message, [this.provider, dynamic originalError])
      : super(message, originalError);
  
  @override
  String toString() => 'NetworkException${provider != null ? ' ($provider)' : ''}: $message';
}

/// Invalid request type exception
class InvalidRequestTypeException extends DoHException {
  final String requestType;
  
  const InvalidRequestTypeException(this.requestType)
      : super('Unsupported DNS request type: $requestType');
  
  @override
  String toString() => 'InvalidRequestTypeException: $message';
}

/// Response parsing exception
class ResponseParsingException extends DoHException {
  const ResponseParsingException(String message, [dynamic originalError])
      : super(message, originalError);
  
  @override
  String toString() => 'ResponseParsingException: $message';
}

/// Cache operation exception
class CacheException extends DoHException {
  const CacheException(String message, [dynamic originalError])
      : super(message, originalError);
  
  @override
  String toString() => 'CacheException: $message';
} 