class DoHResponse {
  int status = 0;
  bool tc = false;
  bool rd = true;
  bool ra = true;
  bool ad = false;
  bool cd = false;
  DoHQuestion question = DoHQuestion();
  List<DoHAnswer> answers = [];

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

  DoHResponse.fromJson(Map<String, dynamic> json) {
    status = (json['Status'] as int?) ?? 0;
    tc = (json['TC'] as bool?) ?? false;
    rd = (json['RD'] as bool?) ?? false;
    ra = (json['TA'] as bool?) ?? false;
    ad = (json['AD'] as bool?) ?? false;
    cd = (json['CD'] as bool?) ?? false;
    question = DoHQuestion.fromJson(json['Question']);
    if (json['Answer'] != null) {
      answers = <DoHAnswer>[];
      json['Answer'].forEach((v) {
        answers.add(DoHAnswer.fromJson(v));
      });
    }
  }

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

class DoHQuestion {
  String name = "";
  int type = 0;

  DoHQuestion({this.name = "", this.type = 0});

  DoHQuestion.fromJson(Map<String, dynamic> json) {
    name = (json['name'] as String?) ?? "";
    type = (json['type'] as int?) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}

class DoHAnswer {
  String name = "";
  int ttl = 0;
  int type = 0;
  String data = "";

  DoHAnswer({this.name = "", this.ttl = 0, this.type = 0, this.data = ""});

  DoHAnswer.fromJson(Map<String, dynamic> json) {
    name = (json['name'] as String?) ?? "";
    ttl = (json['TTL'] as int?) ?? 0;
    type = (json['type'] as int?) ?? 0;
    data = (json['data'] as String?) ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['TTL'] = ttl;
    data['type'] = type;
    data['data'] = this.data;
    return data;
  }
}
