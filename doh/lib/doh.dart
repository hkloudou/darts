library doh;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import './model/doh_response.dart';
import './src/cache.dart';
import './model/doh_enum.dart';
import 'dart:developer' as developer;

export './model/doh_enum.dart' show DohRequestType, DoHProvider;

/// Client for DNS lookup using doh json protocol.
class DoH {
  final DohAnswerCache _cache = DohAnswerCache();
  static final DoH _instance = DoH();
  static DoH get instance => _instance;
  List<Uri> _provider;
  set provider(List<Uri> value) => _provider = value;
  DoH({List<Uri>? provider})
      : _provider = provider ??
            [
              DoHProvider.google2,
              DoHProvider.google1,
              DoHProvider.cloudflare2,
              DoHProvider.cloudflare1,
              DoHProvider.quad9,
              DoHProvider.tw101,
              DoHProvider.alidns,
              DoHProvider.alidns2,
            ],
        assert(provider == null || provider.isNotEmpty);

  /// Lookup a [List<DoHAnswer>], potentially from the cache.
  ///
  /// [domain] is the domain to lookup, and must not be null.
  ///
  /// [type] must be a valid [DohRequestType].
  ///
  /// [cache] we recommanded you keep it `true`
  ///
  /// [dnssec] is developing,TODO
  ///
  /// [timeout] is the timeout per attermt
  ///
  /// [attempt] is the times of retry
  Future<List<T>> lookup<T extends DoHAnswer>(
    String domain,
    DohRequestType type, {
    bool cache = true,
    bool dnssec = false,
    Duration timeout = const Duration(seconds: 5),
    int attempt = 1,
  }) {
    // toLowerCase
    domain = domain.toLowerCase();
    if (cache) {
      final tmpCached = _cache.lookup<T>(domain, type);
      if (tmpCached.isNotEmpty) {
        return Future.value(tmpCached);
      }
    }

    /// internal function
    return _lookup(
      domain,
      type,
      dnssec: dnssec,
      timeout: timeout,
      attempt: attempt,
    ).then((value) {
      if (cache) {
        _cache.updateRecords(value);
      }
      return Future.value(value as List<T>);
    });
  }

  /// kick the cache
  void kick(String name, DohRequestType type) => _cache.kick(name, type);

  /// internal lookup
  Future<List<T>> _lookup<T extends DoHAnswer>(
    String domain,
    DohRequestType type, {
    bool dnssec = false,
    Duration? timeout,
    int attempt = 1,
    int index = 0,
  }) async {
    final int? resType = dohRequestTypeMap[type];
    if (resType == null) {
      return Future.error("can't to resolve Type:$type");
    }
    try {
      final context = SecurityContext.defaultContext;
      var client = HttpClient(context: context);
      client.connectionTimeout = timeout;
      client.badCertificateCallback = (cert, host, port) => true;
      // print(
      //     "index  _provider.length:${_provider.length} $attempt ${index % _provider.length}");
      var provider = _provider[index % _provider.length];
      var url = provider.replace(queryParameters: {
        'name': domain,
        'type': type.toString().replaceFirst('DohRequestType.', ''),
        'dnssec': dnssec ? '1' : '0'
      });
      developer.log(
        "doh looking up from [$provider]: [$domain], type: ${type.toString()}, dnssec: $dnssec",
        name: "doh",
      );
      var request = await client.getUrl(url);
      // Set request http header (need for 'cloudflare' provider)
      request.headers.add('Accept', 'application/dns-json');
      // Close & retrive response
      var response = await request.close();
      var json = await response
          .cast<List<int>>()
          .transform(const Utf8Decoder())
          .join();
      var res = DoHResponse.fromJson(jsonDecode(json));
      if (res.answers.isEmpty) {
        throw ("answers isEmpty");
      }
      for (var i = 0; i < res.answers.length; i++) {
        res.answers[i].name = res.answers[i].name.toLowerCase();
        res.answers[i].provider = provider;
        if (res.answers[i].name.endsWith('.')) {
          res.answers[i].name =
              res.answers[i].name.substring(0, res.answers[i].name.length - 1);
        }
        if (res.answers[i].name != domain && res.answers[i].type == resType) {
          res.answers.add(DoHAnswer(
            name: domain,
            ttl: res.answers[i].ttl,
            type: res.answers[i].type,
            data: res.answers[i].data,
            provider: res.answers[i].provider,
          ));
        }
      }
      var ret = res.answers
          .where((element) => element.type == resType && element.name == domain)
          .toList();
      if (ret.isEmpty) {
        throw ("answers isEmpty");
      }
      return Future.value(ret as List<T>);
    } catch (e) {
      developer.log("resolve error", error: e, name: "doh");
      if (index + 1 < attempt) {
        return _lookup(
          domain,
          type,
          dnssec: dnssec,
          timeout: timeout,
          attempt: attempt,
          index: index + 1,
        );
      }
      rethrow;
    }
  }
}
