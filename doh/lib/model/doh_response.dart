/// DoHResponse
class DoHResponse {
  /// response status
  int status = 0;

  /// tc?
  bool tc = false;

  /// rd?
  bool rd = true;

  /// ta?
  bool ra = true;

  /// ad?
  bool ad = false;

  /// cd?
  bool cd = false;

  /// the question the server understood
  DoHQuestion question = DoHQuestion();

  /// the answers ths server replys
  List<DoHAnswer> answers = [];

  /// init
  DoHResponse({
    this.status = 0,
    this.tc = false,
    this.rd = true,
    this.ra = true,
    this.ad = false,
    this.cd = false,
    required this.question,
    required this.answers,
  });

  /// read from json
  DoHResponse.fromJson(Map<String, dynamic> json) {
    status = (json['Status'] as int?) ?? 0;
    tc = (json['TC'] as bool?) ?? false;
    rd = (json['RD'] as bool?) ?? false;
    ra = (json['TA'] as bool?) ?? false;
    ad = (json['AD'] as bool?) ?? false;
    cd = (json['CD'] as bool?) ?? false;
    if (json['Question'] != null) {
      if (json['Question'] is List<dynamic>) {
        json['Question'].forEach((v) {
          question = DoHQuestion.fromJson(v);
        });
      } else if (json['Question'] is Map<String, dynamic>) {
        question = DoHQuestion.fromJson(json['Question']);
      }
    }
    if (json['Answer'] != null) {
      answers = <DoHAnswer>[];
      json['Answer'].forEach((v) {
        answers.add(DoHAnswer.fromJson(v));
      });
    }
  }

  /// covert to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status'] = status;
    data['TC'] = tc;
    data['RD'] = rd;
    data['RA'] = ra;
    data['AD'] = ad;
    data['CD'] = cd;
    data['Question'] = question.toJson();
    data['Answer'] = answers.map((v) => v.toJson()).toList();
    return data;
  }
}

/// DoHQuestion
class DoHQuestion {
  /// domain name
  String name = "";

  /// Request type
  int type = 0;

  /// init
  DoHQuestion({this.name = "", this.type = 0});

  /// read from json
  DoHQuestion.fromJson(Map<String, dynamic> json) {
    name = (json['name'] as String?) ?? "";
    type = (json['type'] as int?) ?? 0;
  }

  /// covert to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}

/// DoHAnswer
class DoHAnswer {
  /// domain name
  String name = "";

  /// ttl
  int ttl = 0;

  /// doh type
  int type = 0;

  /// data
  String data = "";

  /// validUntil is used for cache
  int validUntil = 0;

  /// provider show who provided the resolve
  Uri? provider;

  /// const
  DoHAnswer({
    this.name = "",
    this.ttl = 0,
    this.type = 0,
    this.data = "",
    this.provider,
  }) : validUntil = DateTime.now().millisecondsSinceEpoch + (ttl * 1000);

  /// read from json
  DoHAnswer.fromJson(Map<String, dynamic> json) {
    name = (json['name'] as String?) ?? "";
    ttl = (json['TTL'] as int?) ?? 0;
    type = (json['type'] as int?) ?? 0;
    data = (json['data'] as String?) ?? "";
    validUntil = DateTime.now().millisecondsSinceEpoch + (ttl * 1000);
  }

  /// covert to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['TTL'] = ttl;
    data['type'] = type;
    data['data'] = this.data;
    data['validUntil'] = validUntil;

    if (provider != null) {
      data['provider'] = provider.toString();
    }
    return data;
  }
}
