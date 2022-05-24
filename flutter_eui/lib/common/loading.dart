import 'dart:async';
import 'package:flutter/material.dart';

bool _isShowing = false;

void showLoading(
  BuildContext context, {
  Widget? child,
  ThemeData? theme,
  bool? isDarkMode,
  String? text,
}) {
  child ??= const CircularProgressIndicator();
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
