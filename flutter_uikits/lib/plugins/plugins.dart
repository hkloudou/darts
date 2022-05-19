import 'package:flutter/widgets.dart';

abstract class UiKitsPluginModel {
  // void xx() {}
  // external factory UiKitsPluginModel.fromJson(Map<String, dynamic> map);
}

// mixin UiKitsPluginWatcherJsoner<Model extends UiKitsPluginModel>
//     on IUiKitsPluginWatcher {
//   void xx() {}
// }
abstract class UiKitsPluginWatcher<Model extends UiKitsPluginModel>
    extends ChangeNotifier {
  Model? get model;
  set model(Model? val);
  void loadJson(Map<String, dynamic> map);
  Widget widget();
  Widget motion({required Widget Function(BuildContext, dynamic) builder});
}
