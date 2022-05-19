import 'package:flutter/foundation.dart';

import 'camel_case.dart';

extension JsonExtension on Map<String, dynamic> {
  T? wjson<T>(String key) {
    var x = (this[key.camelCase] ??
        this[key.pascalCase] ??
        this[this[key.snakeCase]]);
    try {
      return x as T?;
    } catch (e) {
      if (kDebugMode) {
        print("json $T [$key]: $e");
      }
      return null;
    }
  }

  T wjsonOr<T>(String key, T def) => wjson(key) ?? def;
}
