import 'dart:async';

import './base_info.dart';

class BaseLoading {
  final Completer<void> _com = Completer<void>();
  final Completer<void> _comLoadingPage = Completer<void>();
  factory BaseLoading() => _instance;
  static final BaseLoading _instance = BaseLoading._internal();
  late Future<void> _future;
  late Future<void> _futureReady;

  BaseLoading._internal() {
    _futureReady = _comLoadingPage.future.then((_) => BaseInfo.init());
    _future = _futureReady.then((value) => _com.future);
  }
  static BaseLoading get instance => _instance;

  Future<void> get future => _future;
  Future<void> get onReady => _futureReady;

  void pageReady() {
    if (!_comLoadingPage.isCompleted) _comLoadingPage.complete();
  }

  void complete() {
    if (!_com.isCompleted) _com.complete();
  }

  void completeError(Object error) {
    if (!_com.isCompleted) _com.completeError(error);
  }
}
