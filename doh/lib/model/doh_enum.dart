// ignore_for_file: constant_identifier_names

/// DoHProvider defint the popular doh services
class DoHProvider {
  /// google
  static final Uri google1 = Uri.parse('https://8.8.8.8/resolve');
  static final Uri google2 = Uri.parse('https://8.8.4.4/resolve');

  // Quad 101
  // https://dns.twnic.tw/dns-query
  static final Uri tw101 = Uri.parse('https://101.101.101.101/resolve');

  // cloudflare block malicious/porn software
  static final Uri cloudflare1 = Uri.parse('https://1.1.1.1/dns-query');
  static final Uri cloudflare2 = Uri.parse('https://1.0.0.1/dns-query');

  //quad9 block malicious software
  static final Uri quad9 = Uri.parse('https://9.9.9.9:5053/dns-query');

  //alidns with chinese GFW
  static final Uri alidns = Uri.parse('https://223.5.5.5/resolve');
  static final Uri alidns2 = Uri.parse('https://223.6.6.6/resolve');
}

enum DohRequestType { A, AAAA, ALIAS, CNAME, MX, NS, TXT }

final Map<DohRequestType, int> dohRequestTypeMap = <DohRequestType, int>{
  DohRequestType.A: 1,
  DohRequestType.AAAA: 28,
  DohRequestType.CNAME: 5,
  DohRequestType.NS: 2,
  DohRequestType.TXT: 16,
};
