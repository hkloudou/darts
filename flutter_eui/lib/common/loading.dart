import 'dart:async';
import 'package:flutter/material.dart';

bool _isShowing = false;
Widget Function(BuildContext context) _euiDefaultLoadingWidgetBuilder =
    (_) => const CircularProgressIndicator();
Widget Function(BuildContext context) get euiDefaultLoadingWidgetBuilder =>
    _euiDefaultLoadingWidgetBuilder;
set euiDefaultLoadingWidgetBuilder(
        Widget Function(BuildContext context) widgetBuilder) =>
    _euiDefaultLoadingWidgetBuilder = widgetBuilder;

void showLoading(
  BuildContext context, {
  Widget? child,
  ThemeData? theme,
  bool? isDarkMode,
  String? text,
}) {
  child ??= euiDefaultLoadingWidgetBuilder.call(context);
  theme ??= Theme.of(context);
  showDialog(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return Theme(
        data: theme!,
        child: WillPopScope(
          onWillPop: () async {
            return Future.value(false);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              child!,
              text == null
                  ? Container()
                  : DefaultTextStyle(
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: Colors.white),
                      child: Text(text),
                    )
            ],
          ),
        ),
      );
    },
  );
  _isShowing = true;
  // _allowPop = false;
}

void hideLoading(BuildContext context) {
  if (_isShowing) {
    Navigator.maybeOf(context)?.pop();
    _isShowing = false;
  }
}
