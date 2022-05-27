import 'dart:async';

import 'package:flutter/material.dart';

import './base_info.dart';

class BaseLoading {
  final Completer<void> _com = Completer<void>();
  final Completer<BuildContext> _comLoadingPage = Completer<BuildContext>();
  factory BaseLoading() => _instance;
  static final BaseLoading _instance = BaseLoading._internal();
  late Future<void> _future;
  late Future<BuildContext> _futureReady;

  BaseLoading._internal() {
    _futureReady = _comLoadingPage.future.then<BuildContext>((ctx) async {
      await BaseInfo.init();
      return ctx;
    });
    _future = _futureReady.then((_) => _com.future);
  }
  static BaseLoading get instance => _instance;

  Future<void> get future => _future;
  Future<BuildContext> get onReady => _futureReady;

  void pageReady(BuildContext context) {
    if (!_comLoadingPage.isCompleted) _comLoadingPage.complete(context);
  }

  void complete() {
    if (!_com.isCompleted) _com.complete();
  }

  void completeError(Object error) {
    if (!_com.isCompleted) _com.completeError(error);
  }
}
