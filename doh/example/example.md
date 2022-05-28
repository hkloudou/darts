``` dart
import 'package:doh/doh.dart';

void main() {
  var x = await DoH.instance.lookup(
    "www.apple.com",
    DohRequestType.A,
    attempt: 2,
  );
}

```