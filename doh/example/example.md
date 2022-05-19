``` dart
import 'package:doh/doh.dart';

void main() {
  DoH(DoHProvider.alidns).lookup(
    "www.baidu.com",
    RecordType.A,
  );
}

```