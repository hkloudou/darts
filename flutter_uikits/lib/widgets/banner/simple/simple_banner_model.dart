import 'package:flutter_uikits/extensions/json.dart';
import 'package:flutter_uikits/plugins/plugins.dart';

class SimpleBannerModel implements UiKitsPluginModel {
  bool enable = false;
  int width;
  int height;
  List<SimpleBannerModelItem> items;

  SimpleBannerModel._({
    required this.enable,
    required this.width,
    required this.height,
    required this.items,
  });

  factory SimpleBannerModel.fromJson(Map<String, dynamic> map) {
    // return
    return SimpleBannerModel._(
      enable: map.wjsonOr("enable", false),
      width: map.wjsonOr<int>("width", 1900),
      height: map.wjsonOr<int>("height", 800),
      items: map
              .wjson<List<dynamic>>("items")
              ?.map((e) => SimpleBannerModelItem.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }
}

class SimpleBannerModelItem {
  String img;
  String blur;
  String href;

  SimpleBannerModelItem(
      {required this.img, required this.blur, required this.href});

  factory SimpleBannerModelItem.fromJson(Map<String, dynamic> map) {
    return SimpleBannerModelItem(
      img: map.wjsonOr("img", ""),
      blur: map.wjsonOr("blur", ""),
      href: map.wjsonOr("href", ""),
    );
  }
}
