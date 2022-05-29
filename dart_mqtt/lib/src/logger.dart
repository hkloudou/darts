import 'dart:async';
import 'dart:io';

/// Emit a log event.
///
/// This function was designed to map closely to the logging information
/// collected by `package:logging`.
///
/// - [message] is the log message
/// - [time] (optional) is the timestamp
/// - [sequenceNumber] (optional) is a monotonically increasing sequence number
/// - [level] (optional) is the severity level (a value between 0 and 2000); see
///   the `package:logging` `Level` class for an overview of the possible values
/// - [name] (optional) is the name of the source of the log message
/// - [zone] (optional) the zone where the log was emitted
/// - [error] (optional) an error object associated with this log event
/// - [stackTrace] (optional) a stack trace associated with this log event
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
  var ts =
      "\u001b[39;2m${name.padRight(6)}\u001b[0m \u001b[39;2m${DateTime.now().toString().substring(5).substring(0, 17)}\u001b[0m ";
  if (level >= 1000 || error != null || stackTrace != null) {
    stderr.writeln(ts + message);
    if (error != null) {
      stderr.writeln(error.toString());
    }
    if (stackTrace != null) {
      stderr.writeln(stackTrace.toString());
    }
  } else {
    stdout.writeln(ts + message);
  }
}
