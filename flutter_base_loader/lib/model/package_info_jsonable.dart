class BasePackageInfoJsonable {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';
  String buildSignature = '';

  BasePackageInfoJsonable(
      {required this.appName,
      required this.packageName,
      required this.version,
      required this.buildNumber,
      required this.buildSignature});

  BasePackageInfoJsonable.fromJson(Map<String, dynamic> json) {
    appName = json['appName'] ?? appName;
    packageName = json['packageName'] ?? packageName;
    version = json['version'] ?? version;
    buildNumber = json['buildNumber'] ?? buildNumber;
    buildSignature = json['buildSignature'] ?? buildSignature;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appName'] = appName;
    data['packageName'] = packageName;
    data['version'] = version;
    data['buildNumber'] = buildNumber;
    data['buildSignature'] = buildSignature;
    return data;
  }
}
