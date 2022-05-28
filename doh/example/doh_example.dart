import 'dart:convert';

import 'package:doh/doh.dart';

void main() async {
  // DoH.instance.provider = [DoHProvider.cloudflare1];
  var x = await DoH.instance.lookup(
    "www.apple.com",
    DohRequestType.A,
    attempt: 2,
  );
  print(json.encode(x).toString());

  // var host = "www.apple.com";
  // // DoH(provider: DoHProvider)
  // var x = await DoH.instance.lookup(
  //   host,
  //   DohRequestType.A,
  //   attempt: 2,
  // );
  // // DoH.instance.kick(host, DohRequestType.A);
  // print(json.encode(x).toString());
  // x = await DoH.instance.lookup(
  //   host,
  //   DohRequestType.A,
  //   attempt: 2,
  // );
  // print(json.encode(x).toString());
  // await Future.delayed(Duration(seconds: x.first.ttl));
  // x = await DoH.instance.lookup(
  //   host,
  //   DohRequestType.A,
  //   attempt: 2,
  // );
  // print(json.encode(x).toString());
  // print("bye");
}
