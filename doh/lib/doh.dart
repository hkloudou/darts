library doh;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:doh/model/doh_record.dart';

import './model/doh_enum.dart';
import './model/doh_response.dart';
export './model/doh_enum.dart';
export './model/doh_response.dart';
export './model/doh_record.dart';

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
      final context = SecurityContext.defaultContext;
      // context.
      var client = HttpClient(context: context);
      client.connectionTimeout = timeout;
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
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
      // print("json: $json");
      var res = DoHResponse.fromJson(jsonDecode(json));
      if (res.answers.isEmpty) {
        throw ("err lenght");
      }
      return res;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // lookupJsonSecret lookup the json Secret
  Future<DohSecretReccord> lookupJsonSecret(
    String domain, {
    Duration? onFailRetryDuration,
    bool deep = false,
  }) async {
    try {
      var records = (await lookup(domain, RecordType.TXT))
          .answers
          .where((element) => element.type == 16)
          .toList();
      records.shuffle(Random(DateTime.now().microsecondsSinceEpoch));
      var data = DohSecretReccord.fromBase64(records.first.data);
      data.ip = data.host;
      if (deep) {
        data.ip = (await deepLoopupARecord(
          data.host,
          onFailRetryDuration: onFailRetryDuration,
        ));
      }
      return Future.value(data);
    } catch (e) {
      if (onFailRetryDuration == null) rethrow;
      return Future.delayed(onFailRetryDuration).then((_) => lookupJsonSecret(
            domain,
            onFailRetryDuration: onFailRetryDuration,
            deep: deep,
          ));
    }
  }

  Future<String> deepLoopupARecord(
    String domain, {
    Duration? onFailRetryDuration,
  }) async {
    try {
      // return if the record is ip
      var h2 = InternetAddress.tryParse(domain);
      if (h2?.type == InternetAddressType.IPv4 ||
          h2?.type == InternetAddressType.IPv6) {
        return domain;
      }

      // or deep loopup dns A record until it became to ip
      var records = (await lookup(
        domain,
        RecordType.A,
      ))
          .answers
          .where((element) => element.type == 1)
          .toList();
      records.shuffle(Random(DateTime.now().microsecondsSinceEpoch));
      return deepLoopupARecord(records.first.data,
          onFailRetryDuration: onFailRetryDuration);
    } catch (e) {
      if (onFailRetryDuration == null) rethrow;
      return Future.delayed(onFailRetryDuration).then((_) =>
          deepLoopupARecord(domain, onFailRetryDuration: onFailRetryDuration));
    }
  }
}

// class DoHAll {
//   final Duration duration;
//   DoHAll({this.duration = const Duration(seconds: 5)});
//   Future<DoHResponse> lookup(String domain, RecordType type,
//       {bool dnssec = false, Duration? timeout}) async {
//     return Future.any(
//       [
//         DoHProvider.alidns,
//         DoHProvider.alidns2,
//         DoHProvider.quad9,
//         DoHProvider.google,
//         DoHProvider.cloudflare
//       ].map(
//         (e) => DoH(e)
//             .lookup(domain, type, dnssec: dnssec, timeout: timeout)
//             .then((value) => value)
//             .catchError((err) async {
//           await Future.delayed(duration);
//           throw err;
//         }),
//       ),
//     );
//   }
// }
