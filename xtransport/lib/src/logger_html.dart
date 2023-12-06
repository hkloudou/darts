import 'dart:async';

void log(
  String message, {
  DateTime? time,
  int? sequenceNumber,
  int level = 0,
  String name = 'default',
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
}) {
  // if (kweb)

  var ts =
      "\u001b[39;2m${name.padRight(6)}\u001b[0m \u001b[39;2m${DateTime.now().toString().substring(5).substring(0, 17)}\u001b[0m ";
  if (level >= 1000 || error != null || stackTrace != null) {
    // print(object)
    print(ts + message);
    if (error != null) {
      print(error.toString());
    }
    if (stackTrace != null) {
      print(stackTrace.toString());
    }
  } else {
    print(ts + message);
  }
}
