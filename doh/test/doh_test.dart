import 'package:doh/doh.dart';
import 'package:doh/model/doh_record.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    var data = DohSecretReccord(
      host: "lolocalhost",
      authority: "fake.google.com",
      port: 443,
    ).toBase64();
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () async {
      // var recd = await DoH(DoHProvider.alidns).lookupJsonSecret(
      //   "",
      //   onFailRetryDuration: Duration(seconds: 2),
      //   deep: false,
      // );
      // print("recc: ${recd.toString()}");
    });

    test('Encode', () async {
      print(data);
    });
    test('Decode', () async {
      print(DohSecretReccord.fromBase64(data).toString());
    });
  });
}
