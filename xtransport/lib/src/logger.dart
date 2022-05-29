import 'dart:async';
import 'dart:io';

class Logger {
  static log(
    String message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level >= 1000 || error != null) {
      stderr
          .writeln('$message\n${error.toString()}\n${stackTrace?.toString()}');
    } else {
      stdout.writeln(message);
    }
  }
}
