import 'dart:convert';

class DohSecretReccord {
  String host = "";
  String ip = "";
  String? authority;
  int? port;

  // final String x;
  DohSecretReccord(
      {this.host = "localhost", this.ip = "", this.authority, this.port});

  DohSecretReccord.fromBase64(String b64Txt) {
    b64Txt = b64Txt.replaceAll(r'"', "");
    b64Txt = b64Txt.replaceAll(r"'", "");
    var encodedData = base64Url.decode(b64Txt);
    for (var i = 0; i < encodedData.length; i++) {
      encodedData[i] = encodedData[i] ^ (i & 0xFF);
    }
    var res = DohSecretReccord.fromJson(json.decode(utf8.decode(encodedData)));
    host = res.host;
    ip = res.ip;
    authority = res.authority;
    port = res.port;
  }
  String toBase64() {
    var encodedData = utf8.encode(json.encode(toJson()));
    for (var i = 0; i < encodedData.length; i++) {
      encodedData[i] = encodedData[i] ^ (i & 0xFF);
    }
    return base64Url.encode(encodedData);
  }

  // decode from json
  DohSecretReccord.fromJson(Map<String, dynamic> json) {
    host = json['h'] as String? ?? "";
    ip = host;
    authority = json["a"] as String?;
    port = (json["p"] as num?)?.toInt();
  }

  //encode to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['h'] = host;

    // if (ip.isNotEmpty) {
    //   data['i'] = ip;
    // }
    if (authority != null) {
      data["a"] = authority;
    }
    if (port != null) {
      data['p'] = port;
    }
    return data;
  }

  @override
  String toString() => "${json.encode(toJson())} ip:$ip";
}
