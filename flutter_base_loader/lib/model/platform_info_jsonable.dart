class BasePlatformInfoJsonable {
  String operatingSystem = '';
  String operatingSystemVersion = '';
  String dartVersion = '';
  int numberOfProcessors = 0;
  String localHostname = '';

  BasePlatformInfoJsonable({
    required this.operatingSystem,
    required this.operatingSystemVersion,
    required this.dartVersion,
    required this.numberOfProcessors,
    required this.localHostname,
  });

  BasePlatformInfoJsonable.fromJson(Map<String, dynamic> json) {
    operatingSystem = json['operatingSystem'] ?? operatingSystem;
    operatingSystemVersion =
        json['operatingSystemVersion'] ?? operatingSystemVersion;
    dartVersion = json['dartVersion'] ?? dartVersion;
    numberOfProcessors = json['numberOfProcessors'] ?? numberOfProcessors;
    localHostname = json['localHostname'] ?? localHostname;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['operatingSystem'] = operatingSystem;
    data['operatingSystemVersion'] = operatingSystemVersion;
    data['dartVersion'] = dartVersion;
    data['numberOfProcessors'] = numberOfProcessors;
    data['localHostname'] = localHostname;
    return data;
  }
}
