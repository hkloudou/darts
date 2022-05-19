class BaseDeviceInfoJsonable {
  String guid = '';
  String computerName = '';
  String model = '';

  BaseDeviceInfoJsonable(
      {required this.guid, required this.computerName, required this.model});

  BaseDeviceInfoJsonable.fromJson(Map<String, dynamic> json) {
    guid = json['guid'];
    computerName = json['computerName'];
    model = json['model'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['guid'] = guid;
    data['computerName'] = computerName;
    data['model'] = model;
    return data;
  }
}
