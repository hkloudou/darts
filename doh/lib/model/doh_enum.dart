// ignore_for_file: constant_identifier_names

/// DoH Service Providers
/// 
/// Defines endpoint URLs for popular DNS over HTTPS service providers
class DoHProvider {
  /// Google Public DNS - 8.8.8.8
  /// Supports JSON API format
  static final Uri google1 = Uri.parse('https://8.8.8.8/resolve');

  /// Google Public DNS - 8.8.4.4
  /// Supports JSON API format  
  static final Uri google2 = Uri.parse('https://8.8.4.4/resolve');

  /// Taiwan Network Information Center TWNIC - 101.101.101.101
  /// https://101.101.101.101/dns-query
  static final Uri tw101 = Uri.parse('https://101.101.101.101/resolve');

  /// Cloudflare Public DNS - 1.1.1.1
  /// High-performance, privacy-focused DNS service
  static final Uri cloudflare1 = Uri.parse('https://1.1.1.1/dns-query');

  /// Cloudflare Public DNS - 1.0.0.1
  /// Backup endpoint
  static final Uri cloudflare2 = Uri.parse('https://1.0.0.1/dns-query');

  /// Quad9 - 9.9.9.9:5053
  /// DNS service with malware blocking features
  static final Uri quad9 = Uri.parse('https://9.9.9.9:5053/dns-query');

  /// Alibaba Public DNS - 223.5.5.5
  /// Optimized for China mainland, supports ECS
  static final Uri alidns = Uri.parse('https://223.5.5.5/resolve');

  /// Alibaba Public DNS - 223.6.6.6
  /// Backup endpoint
  static final Uri alidns2 = Uri.parse('https://223.6.6.6/resolve');

  /// OpenDNS - 208.67.222.222
  /// Enterprise-grade DNS service
  static final Uri opendns1 = Uri.parse('https://doh.opendns.com/dns-query');

  /// OpenDNS - 208.67.220.220
  /// Backup endpoint
  static final Uri opendns2 = Uri.parse('https://doh.familyshield.opendns.com/dns-query');

  /// AdGuard DNS - 94.140.14.14
  /// DNS with ad blocking features
  static final Uri adguard = Uri.parse('https://dns.adguard.com/dns-query');

  /// DNS.SB - 185.222.222.222
  /// Decentralized DNS service
  static final Uri dnssb = Uri.parse('https://doh.dns.sb/dns-query');

  /// Get all available providers
  static List<Uri> get allProviders => [
        google1,
        google2,
        cloudflare1,
        cloudflare2,
        quad9,
        tw101,
        alidns,
        alidns2,
        opendns1,
        opendns2,
        adguard,
        dnssb,
      ];

  /// Get recommended providers (balanced performance and reliability)
  static List<Uri> get recommendedProviders => [
        cloudflare1,
        google2,
        quad9,
        alidns,
      ];

  /// Get China mainland accessible providers (direct connection without proxy)
  static List<Uri> get chinaDirectProviders => [
        alidns,
        alidns2,
        tw101,
      ];

  /// Get providers that require proxy access in China mainland
  static List<Uri> get chinaProxyProviders => [
        google1,
        google2,
        cloudflare1,
        cloudflare2,
        quad9,
        opendns1,
        opendns2,
        adguard,
        dnssb,
      ];

  /// Get China mainland optimized providers (try direct first, then proxy)
  static List<Uri> get chinaOptimizedProviders => [
        ...chinaDirectProviders,
        ...chinaProxyProviders,
      ];
}

/// DNS record type enumeration
/// 
/// Supports common DNS record types corresponding to RFC standard values
enum DohRequestType {
  /// A record - IPv4 address record
  A('A', 1, 'IPv4 address record'),
  
  /// NS record - Name server record
  NS('NS', 2, 'Name server record'),
  
  /// CNAME record - Canonical name record
  CNAME('CNAME', 5, 'Canonical name record'),
  
  /// SOA record - Start of authority record
  SOA('SOA', 6, 'Start of authority record'),
  
  /// PTR record - Pointer record (reverse DNS lookup)
  PTR('PTR', 12, 'Pointer record'),
  
  /// MX record - Mail exchange record
  MX('MX', 15, 'Mail exchange record'),
  
  /// TXT record - Text record
  TXT('TXT', 16, 'Text record'),
  
  /// AAAA record - IPv6 address record
  AAAA('AAAA', 28, 'IPv6 address record'),
  
  /// SRV record - Service record
  SRV('SRV', 33, 'Service record'),
  
  /// NAPTR record - Naming authority pointer record
  NAPTR('NAPTR', 35, 'Naming authority pointer record'),
  
  /// CERT record - Certificate record
  CERT('CERT', 37, 'Certificate record'),
  
  /// DNAME record - Delegation name record
  DNAME('DNAME', 39, 'Delegation name record'),
  
  /// OPT record - Option record (EDNS)
  OPT('OPT', 41, 'Option record'),
  
  /// DS record - Delegation signer record (DNSSEC)
  DS('DS', 43, 'Delegation signer record'),
  
  /// SSHFP record - SSH public key fingerprint record
  SSHFP('SSHFP', 44, 'SSH public key fingerprint record'),
  
  /// IPSECKEY record - IPSec key record
  IPSECKEY('IPSECKEY', 45, 'IPSec key record'),
  
  /// RRSIG record - Resource record signature (DNSSEC)
  RRSIG('RRSIG', 46, 'Resource record signature'),
  
  /// NSEC record - Next secure record (DNSSEC)
  NSEC('NSEC', 47, 'Next secure record'),
  
  /// DNSKEY record - DNS key record (DNSSEC)
  DNSKEY('DNSKEY', 48, 'DNS key record'),
  
  /// DHCID record - DHCP identifier record
  DHCID('DHCID', 49, 'DHCP identifier record'),
  
  /// NSEC3 record - Next secure record version 3 (DNSSEC)
  NSEC3('NSEC3', 50, 'Next secure record version 3'),
  
  /// NSEC3PARAM record - NSEC3 parameters record (DNSSEC)
  NSEC3PARAM('NSEC3PARAM', 51, 'NSEC3 parameters record'),
  
  /// TLSA record - Transport layer security association record
  TLSA('TLSA', 52, 'Transport layer security association record'),
  
  /// CDS record - Child delegation signer record (DNSSEC)
  CDS('CDS', 59, 'Child delegation signer record'),
  
  /// CDNSKEY record - Child DNS key record (DNSSEC)
  CDNSKEY('CDNSKEY', 60, 'Child DNS key record'),
  
  /// OPENPGPKEY record - OpenPGP public key record
  OPENPGPKEY('OPENPGPKEY', 61, 'OpenPGP public key record'),
  
  /// CSYNC record - Child synchronize record
  CSYNC('CSYNC', 62, 'Child synchronize record'),
  
  /// CAA record - Certificate authority authorization record
  CAA('CAA', 257, 'Certificate authority authorization record'),
  
  /// URI record - Uniform resource identifier record
  URI('URI', 256, 'Uniform resource identifier record'),
  
  /// ALIAS record - Alias record (non-standard)
  ALIAS('ALIAS', 65401, 'Alias record (non-standard)');

  const DohRequestType(this.name, this.value, this.description);

  /// Record type name
  final String name;
  
  /// Corresponding value in RFC standard
  final int value;
  
  /// Description of the record type
  final String description;

  /// Find record type by name
  static DohRequestType? fromName(String name) {
    final upperName = name.toUpperCase();
    for (final type in DohRequestType.values) {
      if (type.name == upperName) {
        return type;
      }
    }
    return null;
  }

  /// Find record type by value
  static DohRequestType? fromValue(int value) {
    for (final type in DohRequestType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }

  /// Get common record types
  static List<DohRequestType> get commonTypes => [
        A,
        AAAA,
        CNAME,
        MX,
        NS,
        TXT,
        SRV,
      ];

  /// Get DNSSEC related record types
  static List<DohRequestType> get dnssecTypes => [
        DS,
        RRSIG,
        NSEC,
        DNSKEY,
        NSEC3,
        NSEC3PARAM,
        CDS,
        CDNSKEY,
      ];

  @override
  String toString() => name;
}

/// DNS record type mapping table
/// 
/// Maps [DohRequestType] enum to corresponding RFC standard values
final Map<DohRequestType, int> dohRequestTypeMap = {
  for (final type in DohRequestType.values) type: type.value,
};

/// DNS response code enumeration
/// 
/// Corresponds to RCODE values in DNS protocol
enum DnsResponseCode {
  /// No error
  noError(0, 'No error'),
  
  /// Format error
  formatError(1, 'Format error'),
  
  /// Server failure
  serverFailure(2, 'Server failure'),
  
  /// Name error (domain does not exist)
  nameError(3, 'Name error (NXDOMAIN)'),
  
  /// Not implemented
  notImplemented(4, 'Not implemented'),
  
  /// Refused
  refused(5, 'Refused');

  const DnsResponseCode(this.value, this.description);

  /// Response code value
  final int value;
  
  /// Response code description
  final String description;

  /// Find response code by value
  static DnsResponseCode? fromValue(int value) {
    for (final code in DnsResponseCode.values) {
      if (code.value == value) {
        return code;
      }
    }
    return null;
  }

  @override
  String toString() => description;
}
