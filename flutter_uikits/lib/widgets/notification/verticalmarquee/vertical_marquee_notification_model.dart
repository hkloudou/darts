import 'package:flutter/material.dart';
import 'package:flutter_uikits/extensions/json.dart';
import 'package:flutter_uikits/plugins/plugins.dart';

class VerticalMarqueeNotificationModel implements UiKitsPluginModel {
  bool enable;
  double iconSize;
  double textSize;
  Color iconColor;
  Color textColor;
  List<VerticalMarqueeNotificationModelItem> items;

  VerticalMarqueeNotificationModel({
    required this.enable,
    required this.iconSize,
    required this.iconColor,
    required this.textSize,
    required this.textColor,
    required this.items,
  });

  factory VerticalMarqueeNotificationModel.fromJson(Map<String, dynamic> map) =>
      VerticalMarqueeNotificationModel(
        enable: map.wjsonOr("enable", false),
        iconSize: double.tryParse(map.wjsonOr("iconSize", "18")) ?? 18.0,
        iconColor: Color(map.wjsonOr("iconColor", Colors.grey.value)),
        textSize: double.tryParse(map.wjsonOr("textSize", "12")) ?? 12.0,
        textColor: Color(map.wjsonOr("textColor", Colors.black.value)),
        items: map
                .wjson<List<dynamic>>("items")
                ?.map((e) => VerticalMarqueeNotificationModelItem.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
      );
}

class VerticalMarqueeNotificationModelItem {
  int updatedAt;
  String title;
  String href;

  VerticalMarqueeNotificationModelItem(
      {required this.updatedAt, required this.title, required this.href});

  factory VerticalMarqueeNotificationModelItem.fromJson(
          Map<String, dynamic> map) =>
      VerticalMarqueeNotificationModelItem(
        updatedAt: map.wjsonOr<int>("updatedAt", 0),
        title: map.wjsonOr("title", ""),
        href: map.wjsonOr("href", ""),
      );
}
