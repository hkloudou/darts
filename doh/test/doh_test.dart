import 'package:doh/doh.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      DoH(DoHProvider.alidns).lookup(
        "www.apple.com",
        RecordType.A,
      );
    });
  });
}
