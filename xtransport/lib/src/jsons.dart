import 'dart:convert';
import 'dart:typed_data';

/// Message
class Message {
  Uint8List message = Uint8List(0);
  RemoteInfo remoteInfo = RemoteInfo();
  LocalInfo localInfo = LocalInfo();

  Message(
      {required this.message,
      required this.remoteInfo,
      required this.localInfo});

  Message.fromJson(Map<String, dynamic> json) {
    if (json['message'] != null) {
      var msg = json['message'];
      if (msg is Uint8List) {
        message = msg;
      } else if (msg is String) {
        message = base64.decode(msg);
      } else {
        message = Uint8List(0);
      }
    }
    remoteInfo = json['remoteInfo'] != null
        ? RemoteInfo.fromJson(json['remoteInfo'])
        : RemoteInfo();
    localInfo = json['localInfo'] != null
        ? LocalInfo.fromJson(json['localInfo'])
        : LocalInfo();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = base64.encode(message.toList());
    // base64.decode(dataTitle)
    data['remoteInfo'] = remoteInfo.toJson();
    data['localInfo'] = localInfo.toJson();
    return data;
  }
}

class RemoteInfo {
  String address = "";
  String host = "";
  String family = "";
  int port = 0;
  int size = 0;

  RemoteInfo({
    this.address = "",
    this.host = "",
    this.family = "",
    this.port = 0,
    this.size = 0,
  });

  RemoteInfo.fromJson(Map<String, dynamic> json) {
    address = json['address'] ?? "";
    host = json['host'] ?? "";
    family = json['family'] ?? "";
    port = json['port'] ?? 0;
    size = json['size'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['host'] = host;
    data['family'] = family;
    data['port'] = port;
    data['size'] = size;
    return data;
  }
}

class LocalInfo {
  String address = "";
  String family = "";
  int port = 0;

  LocalInfo({this.address = "", this.family = "", this.port = 0});

  LocalInfo.fromJson(Map<String, dynamic> json) {
    address = json['address'] ?? "";
    family = json['family'] ?? "";
    port = json['port'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['family'] = family;
    data['port'] = port;
    return data;
  }
}
