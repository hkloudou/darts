``` dart
import 'package:doh/doh.dart';

void main() async{
  // DoH.instance.provider = [DoHProvider.cloudflare1];
  var x = await DoH.instance.lookup(
    "www.apple.com",
    DohRequestType.A,
    attempt: 2,
  );
  print(json.encode(x).toString());
}
```