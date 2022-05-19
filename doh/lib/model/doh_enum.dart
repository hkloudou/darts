// ignore_for_file: constant_identifier_names

class DoHProvider {
  static final Uri google = Uri.parse('https://8.8.8.8/resolve');
  static final Uri cloudflare = Uri.parse('https://1.1.1.1/dns-query');
  static final Uri quad9 = Uri.parse('https://9.9.9.9:5053/dns-query');
  static final Uri alidns = Uri.parse('https://223.5.5.5/resolve');
  static final Uri alidns2 = Uri.parse('https://223.6.6.6/resolve');
}

enum RecordType {
  A,
  AAAA,
  CAA,
  CNAME,
  DNSKEY,
  DS,
  IPSECKEY,
  MX,
  NAPTR,
  NS,
  PTR,
  SPF,
  SRV,
  SSHFP,
  TLSA,
  TXT
}
