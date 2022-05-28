import 'dart:convert';
import 'package:doh/doh.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    // var data = DohSecretReccord(
    //   host: "lolocalhost",
    //   authority: "fake.google.com",
    //   port: 443,
    // ).toBase64();
    // setUp(() {
    //   // Additional setup goes here.
    // });

    test('First Test', () async {
      var x = await DoH.instance.lookup(
        "www.apple.com",
        DohRequestType.A,
      );
      print(json.encode(x).toString());
      // StreamController<String> x = StreamController<String>();
      // x.add("xxx");
      // x.add("yy");
      // // for (final String y in x.stream) {
      // //   print("ret: $y");
      // // }
      // await for (final y in x.stream) {
      //   print("ret: $y");
      // }
      // print("over");
    });

    // test('Encode', () async {
    //   print(data);
    // });
    // test('Decode', () async {
    //   print(DohSecretReccord.fromBase64(data).toString());
    // });
  });
}
