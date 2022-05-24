import 'dart:async';
import 'package:flutter/material.dart';

Future<void> alert(BuildContext context, String tip,
    {bool? isDarkMode,
    bool canDismiss = false,
    bool cancelBtn = false,
    VoidCallback? cb,
    String okText = "",
    String canCelText = ""}) async {
  Completer completer = Completer();
  // Localizations.of(context, type)
  if (okText == "") {
    okText =
        Localizations.of<MaterialLocalizations>(context, MaterialLocalizations)
                ?.okButtonLabel ??
            "Ok";
  }
  if (canCelText == "") {
    canCelText =
        Localizations.of<MaterialLocalizations>(context, MaterialLocalizations)
                ?.cancelButtonLabel ??
            "Cancel";
  }
  showDialog(
    context: context,
    barrierDismissible: canDismiss || cancelBtn, // user must tap button!
    builder: (BuildContext context) {
      return Theme(
        data: Theme.of(context),
        child: WillPopScope(
            onWillPop: () async {
              return Future.value(canDismiss || cancelBtn);
            },
            child: AlertDialog(
              content: Text(tip),
              actions: <Widget>[
                (cancelBtn)
                    ? TextButton(
                        child: Text(canCelText),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : Container(),
                TextButton(
                  child: Text(okText),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                    if (cb != null) {
                      cb();
                    }
                  },
                ),
              ],
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            )),
      );
    },
  );
  return completer.future;
}
