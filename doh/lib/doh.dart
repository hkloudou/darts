library doh;

import 'dart:convert';
import 'dart:io';

import './model/doh_enum.dart';
import './model/doh_response.dart';
export './model/doh_enum.dart';
export './model/doh_response.dart';

class DoH {
  final Uri provider;
  // final Duration duration;
  DoH(this.provider);

  Future<DoHResponse> lookup(String domain, RecordType type,
      {bool dnssec = false, Duration? timeout}) async {
    try {
      // Init HttpClient
      // HttpRequest.getString(path);
      // if (kIsWeb) {
      //   HttpRequest.getString('users.json?name=$name&id=$id')
      //       .then((String resp) {
      //     // Do something with the response.
      //   });
      // }

      var client = HttpClient();
      client.connectionTimeout = timeout;

      // Init request query parameters and send request
      var request = await client.getUrl(provider.replace(queryParameters: {
        'name': domain,
        'type': type.toString().replaceFirst('RecordType.', ''),
        'dnssec': dnssec ? '1' : '0'
      }));
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
        throw ("err lenght");
      }
      return res;
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}

class DoHAll {
  final Duration duration;
  DoHAll({this.duration = const Duration(seconds: 5)});
  Future<DoHResponse> lookup(String domain, RecordType type,
      {bool dnssec = false, Duration? timeout}) async {
    return Future.any(
      [
        DoHProvider.alidns,
        DoHProvider.alidns2,
        DoHProvider.quad9,
        DoHProvider.google,
        DoHProvider.cloudflare
      ].map(
        (e) => DoH(e)
            .lookup(domain, type, dnssec: dnssec, timeout: timeout)
            .then((value) => value)
            .catchError((err) async {
          await Future.delayed(duration);
          throw err;
        }),
      ),
    );
  }
}
