import 'dart:mirrors';

Type _typeOf<T>() => T;

List<int> _directReturn = [
  _typeOf<Map<String, dynamic>>().hashCode,
  _typeOf<String>().hashCode,
  _typeOf<int>().hashCode,
];
T _getJsonObject<T>(dynamic _json) {
  if (_directReturn.contains(_typeOf<T>().hashCode)) {
    return _json as T;
  }
  try {
    return reflectClass(T)
        .newInstance(const Symbol('fromJson'), [_json]).reflectee as T;
  } catch (e) {
    return _json as T;
  }
}

// @JsonSerializable(fieldRename: FieldRename.none)
// @immutable
class HttpJsonPackage<T> {
  int _c = -1;
  String _m = "";
  List<T> _d;
  List<T> get datas {
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
  factory HttpJsonPackage.fromJson(Map<String, dynamic>? json) {
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
    if (code != 0 || _typeOf<T>().hashCode == _typeOf<void>().hashCode) {
      return HttpJsonPackage<T>(code, msg, []);
    }

    var data = json?['d'] ??
        json?['D'] ??
        json?['data'] ??
        json?['Data'] ??
        json?['DATA'];

    if (data is List) {
      return HttpJsonPackage<T>(
          code, msg, data.map((e) => _getJsonObject<T>(e)).toList());
    }
    return HttpJsonPackage<T>(code, msg, [(_getJsonObject<T>(data))]);
    // return HttpJsonPackage<T>.cancel();
  }
  Map<String, dynamic> toJson() {
    return {
      "c": _c,
      "m": _m,
      "d": _d,
    };
  }

  factory HttpJsonPackage.cancel() {
    return HttpJsonPackage<T>(-999, "", []);
  }

  factory HttpJsonPackage.error(int code, String msg) {
    return HttpJsonPackage<T>(code, msg, []);
  }
}
