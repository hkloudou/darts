import 'package:flutter/material.dart';

class EConfig {
  EConfig._internal();
  static final EConfig _default = EConfig._internal();
  static EConfig get instance => _default;
  factory EConfig() => _default;

  // loading ui
  Widget Function(BuildContext context) _euiDefaultLoadingWidgetBuilder =
      (_) => const CircularProgressIndicator();
  // get the loading Widget
  Widget getLoadingWidget(BuildContext context) {
    return _euiDefaultLoadingWidgetBuilder.call(context);
  }

  // set the LoadingBuiler
  void setLoadingBuiler(Widget Function(BuildContext context) widgetBuilder) =>
      _euiDefaultLoadingWidgetBuilder = widgetBuilder;
}
