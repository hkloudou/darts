typedef JsonHandlerCallBack<T> = T Function(dynamic json);
Type _typeOf<T>() => T;

final _jsonHandlerCallBackMap = <Type, JsonHandlerCallBack>{};

/// Registers a decoder for [T]; a `List<T>` decoder is registered automatically.
void registerJsonHandler<T>(JsonHandlerCallBack<T> handle) {
  _jsonHandlerCallBackMap[T] = handle;
  _jsonHandlerCallBackMap[_typeOf<List<T>>()] = (dynamic obj) {
    return (obj as List<dynamic>?)?.map((e) => handle(e)).toList() ?? <T>[];
  };
}

@Deprecated('Use registerJsonHandler')
void registeJsonHandle<T>(JsonHandlerCallBack<T> handle) =>
    registerJsonHandler<T>(handle);

T fromJson<T>(dynamic json) {
  final handler = _jsonHandlerCallBackMap[T];
  if (handler != null) {
    return handler(json) as T;
  }
  return json as T;
}

/// A `{code, msg, data}` envelope decoded from a JSON response body.
class HttpJsonPackage<T> {
  final int _c;
  final String _m;
  final T? _d;

  T? get data => _d;

  int get code => _c;

  String get msg => _m;

  /// True when this package was produced by [HttpJsonPackage.cancel].
  bool get canceled => _c == -999;

  @Deprecated('Use canceled')
  bool get canced => canceled;

  const HttpJsonPackage(this._c, this._m, this._d);

  factory HttpJsonPackage.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (_typeOf<T>() == dynamic) {
      throw ArgumentError(
          'HttpJsonPackage.fromJson requires an explicit type argument; '
          'register a handler for T via registerJsonHandler');
    }
    // 读取原生包，然后用兼容模式吧
    var code = json?['c'] as int? ??
        json?['C'] as int? ??
        json?['code'] as int? ??
        json?['Code'] as int? ??
        json?['CODE'] as int? ??
        -1;
    var msg = json?['m'] as String? ??
        json?['M'] as String? ??
        json?['msg'] as String? ??
        json?['Msg'] as String? ??
        json?['MSG'] as String? ??
        json?['message'] as String? ??
        json?['Message'] as String? ??
        json?['MESSAGE'] as String? ??
        "";
    // 如果是空的话，就返回空就好
    if (_typeOf<T>() == _typeOf<void>()) {
      return HttpJsonPackage<T>(code, msg, null);
    }
    T? data;
    try {
      data = fromJson<T>(json?['d'] ??
          json?['D'] ??
          json?['data'] ??
          json?['Data'] ??
          json?['DATA']);
    } catch (e) {
      return HttpJsonPackage<T>(
        -1,
        "err:$e",
        null,
      );
    }
    return HttpJsonPackage<T>(
      code,
      msg,
      data,
    );
  }

  factory HttpJsonPackage.cancel() {
    return HttpJsonPackage<T>(-999, "", null);
  }

  factory HttpJsonPackage.error(int code, String msg) {
    return HttpJsonPackage<T>(code, msg, null);
  }
}
