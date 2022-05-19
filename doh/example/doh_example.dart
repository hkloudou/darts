import 'package:doh/doh.dart';

void main() {
  DoH(DoHProvider.alidns).lookup(
    "www.apple.com",
    RecordType.A,
  );
}
