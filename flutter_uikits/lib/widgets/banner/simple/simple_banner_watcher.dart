import 'package:flutter/material.dart';
import 'simple_banner_model.dart';
import 'simple_banner_widget.dart';
import 'package:flutter_uikits/common/builder.dart';
import 'package:flutter_uikits/plugins/plugins.dart';

class SimpleBannerWatcher extends ChangeNotifier
    implements UiKitsPluginWatcher<SimpleBannerModel> {
  static final _cache = <String, SimpleBannerWatcher>{};
  SimpleBannerModel? _model;
  @override
  set model(SimpleBannerModel? val) {
    _model = val;
    notifyListeners();
  }

  @override
  SimpleBannerModel? get model => _model;

  @override
  void loadJson(Map<String, dynamic> map) {
    try {
      model = SimpleBannerModel.fromJson(map);
    } catch (e) {
      model = null;
    }
  }

  SimpleBannerWatcher._();

  factory SimpleBannerWatcher.of(String key) {
    _cache[key] = _cache[key] ?? SimpleBannerWatcher._();
    return _cache[key]!;
  }
  int get width => _model?.width ?? 0;
  int get height => _model?.height ?? 0;
  double get hwAspect => width == 0 ? 0 : height / width;
  double get whAspect => height == 0 ? 0 : width / height;

  double visiableHeight(double width) =>
      (_model == null || !_model!.enable || _model!.items.isEmpty)
          ? 0
          : width * hwAspect;

  @override
  Widget widget() => motion(builder: (_, p1) => raw());

  Widget raw() => SimpleBannerWidget(
        model: _model,
      );
  @override
  Widget motion(
          {required Widget Function(BuildContext, SimpleBannerWatcher)
              builder}) =>
      ChangeNotifierBuilder<SimpleBannerWatcher>(
        value: this,
        builder: builder,
      );
}
