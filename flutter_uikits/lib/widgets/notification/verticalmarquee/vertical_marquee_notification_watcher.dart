import 'package:flutter/widgets.dart';
import 'package:flutter_uikits/plugins/plugins.dart';
import 'vertical_marquee_notification_widget.dart';
import 'vertical_marquee_notification_model.dart';
import 'package:flutter_uikits/common/builder.dart';

class VerticalMarqueeNotificationWatcher extends ChangeNotifier
    implements UiKitsPluginWatcher<VerticalMarqueeNotificationModel> {
  static final _cache = <String, VerticalMarqueeNotificationWatcher>{};
  VerticalMarqueeNotificationModel? _model;

  @override
  set model(VerticalMarqueeNotificationModel? val) {
    _model = val;
    notifyListeners();
  }

  @override
  VerticalMarqueeNotificationModel? get model => _model;

  VerticalMarqueeNotificationWatcher._();

  factory VerticalMarqueeNotificationWatcher.of(String key) {
    _cache[key] = _cache[key] ?? VerticalMarqueeNotificationWatcher._();
    return _cache[key]!;
  }
  @override
  void loadJson(Map<String, dynamic> map) {
    try {
      model = VerticalMarqueeNotificationModel.fromJson(map);
    } catch (e) {
      model = null;
    }
  }

  double get visiableHeight =>
      (_model == null || !_model!.enable || _model!.items.isEmpty) ? 0 : 36;

  @override
  Widget widget({
    Color? iconColor,
    Color? textColor,
    double? iconSize,
    double? textSize,
  }) =>
      motion(
          builder: ((p0, p1) => raw(
                iconColor: iconColor,
                iconSize: iconSize,
                textColor: textColor,
                textSize: textSize,
              )));

  Widget raw({
    Color? iconColor,
    Color? textColor,
    double? iconSize,
    double? textSize,
  }) =>
      VerticalMarqueeNotificationWidget(
        model: model,
        iconColor: iconColor,
        iconSize: iconSize,
        textColor: textColor,
        textSize: textSize,
      );
  @override
  Widget motion(
          {required Widget Function(BuildContext context,
                  VerticalMarqueeNotificationWatcher model)
              builder}) =>
      ChangeNotifierBuilder<VerticalMarqueeNotificationWatcher>(
        value: this,
        builder: builder,
      );
}
