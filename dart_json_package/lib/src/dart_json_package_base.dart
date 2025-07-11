typedef JsonHandlerCallBack<T> = T Function(dynamic json);
Type _typeOf<T>() => T;

var _jsonHandlerCallBackMap = <int, JsonHandlerCallBack>{};
void registeJsonHandle<T>(JsonHandlerCallBack<T> handle) {
  _jsonHandlerCallBackMap[_typeOf<T>().hashCode] = handle;
  _jsonHandlerCallBackMap[_typeOf<List<T>>().hashCode] = ((dynamic obj) {
    var x = (obj as List<dynamic>?)?.map((e) => handle(e)).toList() ?? [];
    return x;
  });
}

List<int> _directReturn = [
  _typeOf<Map<String, dynamic>>().hashCode,
  _typeOf<String>().hashCode,
  _typeOf<int>().hashCode,
];

T fromJson<T>(dynamic json) {
  if (_jsonHandlerCallBackMap.containsKey(T.hashCode)) {
    return _jsonHandlerCallBackMap[T.hashCode]!(json) as T;
  }
  if (_directReturn.contains(T.hashCode)) {
    return json as T;
  }

  return json as T;
}

// @JsonSerializable(fieldRename: FieldRename.none)
// @immutable
class HttpJsonPackage<T> {
  int _c = -1;
  String _m = "";
  T? _d;
  T? get data {
    return this._d;
  }

  int get code {
    return this._c;
  }

  String get msg {
    return this._m;
  }

  bool get canced {
    return _c == -999;
  }

  HttpJsonPackage(this._c, this._m, this._d);
  static Type _typeOf<T>() => T;
  @override
  factory HttpJsonPackage.fromJson(
    Map<String, dynamic>? json,
  ) {
    // print(T);
    if (_typeOf<T>().hashCode == _typeOf<dynamic>().hashCode) {
      throw "please use type HttpJsonPackage.fromJson<Type> Type extends fromJson";
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
        json?['MSSSAGE'] as String? ??
        "";
    // 如果是空的话，就返回空就好
    if (_typeOf<T>().hashCode == _typeOf<void>().hashCode) {
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
        "err:" + e.toString(),
        null,
      );
    }
    return HttpJsonPackage<T>(
      code,
      msg,
      data,
    );
  }
  // Map<String, dynamic> toJson() {
  //   return {
  //     "c": _c,
  //     "m": _m,
  //     "d": _d,
  //   };
  // }

  factory HttpJsonPackage.cancel() {
    return HttpJsonPackage<T>(-999, "", null);
  }

  factory HttpJsonPackage.error(int code, String msg) {
    return HttpJsonPackage<T>(code, msg, null);
  }
}
