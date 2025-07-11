import 'doh_enum.dart';

/// DNS over HTTPS Response
/// 
/// Represents a complete response from DoH server, including query status, questions and answer records.
/// Complies with RFC 8484 and related DNS standards.
class DoHResponse {
  /// DNS response status code (RCODE)
  /// 0 = NOERROR, 1 = FORMERR, 2 = SERVFAIL, 3 = NXDOMAIN, etc.
  final int status;

  /// Truncation flag (TC) - whether response was truncated due to size
  final bool tc;

  /// Recursion desired flag (RD) - whether client requested recursive query
  final bool rd;

  /// Recursion available flag (RA) - whether server supports recursive queries
  final bool ra;

  /// Authenticated data flag (AD) - whether answer is DNSSEC validated
  final bool ad;

  /// Checking disabled flag (CD) - whether DNSSEC checking is disabled
  final bool cd;

  /// Original query question
  final DoHQuestion question;

  /// DNS answer record list
  final List<DoHAnswer> answers;

  /// Authority record list (optional)
  final List<DoHAnswer> authority;

  /// Additional record list (optional)
  final List<DoHAnswer> additional;

  /// Create DoH response instance
  const DoHResponse({
    required this.status,
    required this.tc,
    required this.rd,
    required this.ra,
    required this.ad,
    required this.cd,
    required this.question,
    required this.answers,
    this.authority = const [],
    this.additional = const [],
  });

  /// Create DoH response from JSON
  /// 
  /// Supports standard DoH JSON format as defined in RFC 8484
  factory DoHResponse.fromJson(Map<String, dynamic> json) {
    try {
      final status = (json['Status'] as int?) ?? 0;
      final tc = (json['TC'] as bool?) ?? false;
      final rd = (json['RD'] as bool?) ?? true;
      final ra = (json['RA'] as bool?) ?? true; // Note: Fixed from original TA error
      final ad = (json['AD'] as bool?) ?? false;
      final cd = (json['CD'] as bool?) ?? false;

      // Parse question section
      DoHQuestion question = const DoHQuestion();
      if (json['Question'] != null) {
        if (json['Question'] is List && (json['Question'] as List).isNotEmpty) {
          question = DoHQuestion.fromJson(json['Question'][0] as Map<String, dynamic>);
        } else if (json['Question'] is Map<String, dynamic>) {
          question = DoHQuestion.fromJson(json['Question'] as Map<String, dynamic>);
        }
      }

      // Parse answer section
      final answers = <DoHAnswer>[];
      if (json['Answer'] is List) {
        for (final answerJson in json['Answer'] as List) {
          if (answerJson is Map<String, dynamic>) {
            answers.add(DoHAnswer.fromJson(answerJson));
          }
        }
      }

      // Parse authority section
      final authority = <DoHAnswer>[];
      if (json['Authority'] is List) {
        for (final authJson in json['Authority'] as List) {
          if (authJson is Map<String, dynamic>) {
            authority.add(DoHAnswer.fromJson(authJson));
          }
        }
      }

      // Parse additional section
      final additional = <DoHAnswer>[];
      if (json['Additional'] is List) {
        for (final addJson in json['Additional'] as List) {
          if (addJson is Map<String, dynamic>) {
            additional.add(DoHAnswer.fromJson(addJson));
          }
        }
      }

      return DoHResponse(
        status: status,
        tc: tc,
        rd: rd,
        ra: ra,
        ad: ad,
        cd: cd,
        question: question,
        answers: answers,
        authority: authority,
        additional: additional,
      );
    } catch (e) {
      throw FormatException('Invalid DoH response JSON: $e');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'Status': status,
      'TC': tc,
      'RD': rd,
      'RA': ra,
      'AD': ad,
      'CD': cd,
      'Question': [question.toJson()],
      'Answer': answers.map((v) => v.toJson()).toList(),
    };

    if (authority.isNotEmpty) {
      data['Authority'] = authority.map((v) => v.toJson()).toList();
    }

    if (additional.isNotEmpty) {
      data['Additional'] = additional.map((v) => v.toJson()).toList();
    }

    return data;
  }

  /// Check if response is successful
  bool get isSuccessful => status == 0;

  /// Get response status description
  String get statusDescription {
    final responseCode = DnsResponseCode.fromValue(status);
    return responseCode?.description ?? 'Unknown status code: $status';
  }

  /// Check if there are any answer records
  bool get hasAnswers => answers.isNotEmpty;

  /// Check if DNSSEC validated
  bool get isSecure => ad;

  /// Get all records (answers + authority + additional)
  List<DoHAnswer> get allRecords => [...answers, ...authority, ...additional];

  @override
  String toString() => 'DoHResponse(status: $status, answers: ${answers.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoHResponse &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          question == other.question &&
          answers.length == other.answers.length;

  @override
  int get hashCode => status.hashCode ^ question.hashCode ^ answers.length.hashCode;
}

/// DNS query question
/// 
/// Represents a query request sent from client to DNS server
class DoHQuestion {
  /// Query domain name
  final String name;

  /// DNS record type (e.g., A=1, AAAA=28, etc.)
  final int type;

  /// DNS class (usually IN=1 for Internet)
  final int dnsClass;

  /// Create DNS question instance
  const DoHQuestion({
    this.name = '',
    this.type = 0,
    this.dnsClass = 1, // Default to Internet class
  });

  /// Create DNS question from JSON
  factory DoHQuestion.fromJson(Map<String, dynamic> json) {
    return DoHQuestion(
      name: (json['name'] as String?) ?? '',
      type: (json['type'] as int?) ?? 0,
      dnsClass: (json['class'] as int?) ?? 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'class': dnsClass,
    };
  }

  /// Get record type name
  String get typeName {
    final requestType = DohRequestType.fromValue(type);
    return requestType?.name ?? 'TYPE$type';
  }

  /// Check if it's a valid question
  bool get isValid => name.isNotEmpty && type > 0;

  @override
  String toString() => 'DoHQuestion(name: $name, type: $typeName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoHQuestion &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          dnsClass == other.dnsClass;

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ dnsClass.hashCode;
}

/// DNS answer record
/// 
/// Represents a single response record from DNS query, including domain name, type, TTL and data
class DoHAnswer {
  /// Domain name
  String name;

  /// Time to live (seconds)
  final int ttl;

  /// DNS record type
  final int type;

  /// DNS class (usually IN=1)
  final int dnsClass;

  /// Record data (IP address, domain name, etc.)
  final String data;

  /// Record expiration timestamp (milliseconds)
  int validUntil;

  /// DoH server that provided this record
  Uri? provider;

  /// Record length (bytes)
  final int? dataLength;

  /// Create DNS answer record
  DoHAnswer({
    required this.name,
    required this.ttl,
    required this.type,
    required this.data,
    this.dnsClass = 1,
    this.provider,
    this.dataLength,
    int? validUntil,
  }) : validUntil = validUntil ?? (DateTime.now().millisecondsSinceEpoch + (ttl * 1000));

  /// Create DNS answer record from JSON
  factory DoHAnswer.fromJson(Map<String, dynamic> json) {
    final ttl = (json['TTL'] as int?) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    return DoHAnswer(
      name: (json['name'] as String?) ?? '',
      ttl: ttl,
      type: (json['type'] as int?) ?? 0,
      dnsClass: (json['class'] as int?) ?? 1,
      data: (json['data'] as String?) ?? '',
      dataLength: json['rdlength'] as int?,
      validUntil: currentTime + (ttl * 1000),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'TTL': ttl,
      'type': type,
      'class': dnsClass,
      'data': this.data,
      'validUntil': validUntil,
    };

    if (provider != null) {
      data['provider'] = provider.toString();
    }

    if (dataLength != null) {
      data['rdlength'] = dataLength;
    }

    return data;
  }

  /// Get record type name
  String get typeName {
    final requestType = DohRequestType.fromValue(type);
    return requestType?.name ?? 'TYPE$type';
  }

  /// Check if record has expired
  bool get isExpired => DateTime.now().millisecondsSinceEpoch > validUntil;

  /// Get remaining TTL (seconds)
  int get remainingTtl {
    final remaining = (validUntil - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if it's a valid record
  bool get isValid => name.isNotEmpty && type > 0 && data.isNotEmpty;

  /// Refresh expiration time (recalculate validUntil)
  void refreshValidUntil() {
    validUntil = DateTime.now().millisecondsSinceEpoch + (ttl * 1000);
  }

  /// Check if record matches specified query
  bool matches(String queryName, int queryType) {
    return name.toLowerCase() == queryName.toLowerCase() && type == queryType;
  }

  @override
  String toString() => 'DoHAnswer(name: $name, type: $typeName, data: $data, ttl: ${remainingTtl}s)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoHAnswer &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          data == other.data;

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ data.hashCode;
}
