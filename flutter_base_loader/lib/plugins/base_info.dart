import 'dart:io';

import 'package:flutter/foundation.dart';
import '../model/device_info_jsonable.dart';
import '../model/package_info_jsonable.dart';
import '../model/platform_info_jsonable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class BaseInfo {
  static late BasePackageInfoJsonable package;
  static late BasePlatformInfoJsonable platform;
  static late BaseDeviceInfoJsonable device;

  static Future<void> init() async {
    await _initPackageInfo();
    await _initPlatformInfo();
    await _initDeviceInfo();
    return Future.value();
  }

  static Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['package'] = package.toJson();
    data['platform'] = platform.toJson();
    data['device'] = device.toJson();
    return data;
  }

  //_initPackageInfo internal method
  static Future<BasePackageInfoJsonable> _initPackageInfo() async {
    var packageInfo = await PackageInfo.fromPlatform();
    package = BasePackageInfoJsonable(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
    );
    return Future.value(package);
  }

  static Future<BasePlatformInfoJsonable> _initPlatformInfo() async {
    platform = BasePlatformInfoJsonable(
      operatingSystem: kIsWeb ? 'web' : Platform.operatingSystem,
      operatingSystemVersion: kIsWeb ? '' : Platform.operatingSystemVersion,
      dartVersion: kIsWeb ? '' : Platform.version,
      numberOfProcessors: kIsWeb ? 0 : Platform.numberOfProcessors,
      localHostname: kIsWeb ? '' : Platform.localHostname,
    );
    return Future.value(platform);
  }

  static Future<BaseDeviceInfoJsonable> _initDeviceInfo() async {
    const key = 'system_guid';

    final prefs = await SharedPreferences.getInstance();
    final info = DeviceInfoPlugin();

    var guid = prefs.getString(key) ?? '';
    var computerName = '';
    var model = '';
    if (guid.isEmpty) {
      if (kIsWeb) {
        final data = await info.webBrowserInfo;
        // guid = _data ?? "";
        computerName = data.browserName.toString();
        model = data.browserName.toString();
      } else if (Platform.isAndroid) {
        final data = await info.androidInfo;
        guid = data.androidId ?? '';
        computerName = data.host ?? '';
        model = data.model ?? '';
        // _data.device
      } else if (Platform.isIOS) {
        final data = await info.iosInfo;
        guid = data.identifierForVendor ?? '';
        computerName = data.name ?? '';
        model = data.model ?? '';
      } else if (Platform.isLinux) {
        final data = await info.linuxInfo;
        guid = data.machineId ?? '';
        model = data.prettyName;
        // hostname=_data.
      } else if (Platform.isMacOS) {
        final data = await info.macOsInfo;
        guid = data.systemGUID ?? '';
        computerName = data.computerName;
        model = data.model;
      } else if (Platform.isWindows) {
        final data = await info.windowsInfo;
        computerName = data.computerName;
        model = data.computerName;
      }
    }
    //set guid as random
    if (guid.isEmpty) {
      guid = const Uuid().v4();
      await prefs.setString(key, guid);
    }
    device = BaseDeviceInfoJsonable(
      guid: guid,
      computerName: computerName,
      model: model,
    );
    return Future.value(device);
  }
}
