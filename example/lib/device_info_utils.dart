import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceInfoUtils {
  DeviceInfoUtils._();

  static final deviceInfoPlugin = DeviceInfoPlugin();
  static DeviceInfoModel? deviceInfoModel;

  static bool get isDesktop => !isWeb && (isWindows || isLinux || isMacOS);
  static bool get isMobile => isAndroid || isIOS;
  static bool get isWeb => kIsWeb;

  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isFuchsia => Platform.isFuchsia;
  static bool get isIOS => Platform.isIOS;

  static Future<String?> get deviceUuid => _getDeviceUUID();
  static Future<bool?> get isPhysicalDevice => _isPhysicalDevice();
  static Future<DeviceInfoModel?> get deviceInfo => _getDeviceInfo();
  static double safeAreaBottom(BuildContext c) => _safeAreaBottom(c);

  static Future<String?> _getDeviceUUID() async {
    await _getDeviceInfo();
    return deviceInfoModel?.deviceUUID;
  }

  static Future<bool?> _isPhysicalDevice() async {
    await _getDeviceInfo();
    return deviceInfoModel?.isPhysicalDevice;
  }

  static Future<DeviceInfoModel?> _getDeviceInfo() async {
    try {
      if (deviceInfoModel == null) {
        if (Platform.isAndroid) {
          final info = await deviceInfoPlugin.androidInfo;
          deviceInfoModel = DeviceInfoModel.fromAndroid(info);
        } else if (Platform.isIOS) {
          final info = await deviceInfoPlugin.iosInfo;
          deviceInfoModel = DeviceInfoModel.fromIos(info);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[DeviceInfo][_getDeviceInfo] $e');
      }
    }
    return deviceInfoModel;
  }

  static double _safeAreaBottom(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final safeKeyboard = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets,
      WidgetsBinding.instance.window.devicePixelRatio,
    ).bottom;
    final rs = max(safeBottom, safeKeyboard);
    return rs;
  }
}

class DeviceInfoModel {
  // Common
  bool? isPhysicalDevice;
  String? deviceUUID;
  String? release;
  String? model;

  // iOS
  String? name;
  String? systemName;
  String? systemVersion;
  String? localizedModel;
  String? sysname;
  String? nodename;
  String? version;
  String? machine;

  // Android
  String? baseOS;
  int? previewSdkInt;
  String? securityPatch;
  String? codename;
  String? incremental;
  int? sdkInt;
  String? board;
  String? bootloader;
  String? brand;
  String? device;
  String? display;
  String? fingerprint;
  String? hardware;
  String? host;
  String? id;
  String? manufacturer;
  String? product;
  List<String?>? supported32BitAbis;
  List<dynamic>? supported64BitAbis;
  List<String?>? supportedAbis;
  String? tags;
  String? type;
  List<String?>? systemFeatures;

  DeviceInfoModel.fromIos(IosDeviceInfo info) {
    isPhysicalDevice = info.isPhysicalDevice;
    deviceUUID = info.identifierForVendor;
    name = info.name;
    systemName = info.systemName;
    systemVersion = info.systemVersion;
    model = info.model;
    localizedModel = info.localizedModel;
    //uts_name
    sysname = info.utsname.sysname;
    nodename = info.utsname.nodename;
    release = info.utsname.release;
    version = info.utsname.version;
    machine = info.utsname.machine;
  }

  DeviceInfoModel.fromAndroid(AndroidDeviceInfo info) {
    isPhysicalDevice = info.isPhysicalDevice;
    deviceUUID = info.id;

    baseOS = info.version.baseOS;
    previewSdkInt = info.version.previewSdkInt;
    securityPatch = info.version.securityPatch;
    codename = info.version.codename;
    incremental = info.version.incremental;
    release = info.version.release;
    sdkInt = info.version.sdkInt;

    board = info.board;
    bootloader = info.bootloader;
    brand = info.brand;
    device = info.device;
    display = info.display;
    fingerprint = info.fingerprint;
    hardware = info.hardware;
    host = info.host;
    id = info.id;
    manufacturer = info.manufacturer;
    model = info.model;
    product = info.product;
    supported32BitAbis = info.supported32BitAbis;
    supported64BitAbis = info.supported64BitAbis;
    supportedAbis = info.supportedAbis;
    tags = info.tags;
    type = info.type;
    systemFeatures = info.systemFeatures;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['deviceUUID'] = deviceUUID;
    json['isPhysicalDevice'] = isPhysicalDevice;
    json['model'] = model;
    json['release'] = release;

    json['name'] = name;
    json['systemVersion'] = systemVersion;
    json['machine'] = machine;

    json['systemName'] = systemName;
    json['localizedModel'] = localizedModel;
    json['sysname'] = sysname;
    json['nodename'] = nodename;
    json['version'] = version;
    json['baseOS'] = baseOS;
    json['previewSdkInt'] = previewSdkInt;
    json['securityPatch'] = securityPatch;
    json['codename'] = codename;
    json['incremental'] = incremental;

    json['sdkInt'] = sdkInt;
    json['manufacturer'] = manufacturer;
    json['product'] = product;

    json['board'] = board;
    json['bootloader'] = bootloader;
    json['brand'] = brand;
    json['device'] = device;
    json['display'] = display;
    json['fingerprint'] = fingerprint;
    json['hardware'] = hardware;
    json['host'] = host;
    json['id'] = id;
    json['supported32BitAbis'] = supported32BitAbis;
    json['supported64BitAbis'] = supported64BitAbis;
    json['supportedAbis'] = supportedAbis;
    json['tags'] = tags;
    json['type'] = type;
    json['systemFeatures'] = systemFeatures;
    json.removeWhere((key, value) => value == null);
    return json;
  }

  Map<String, dynamic> toShortJson() {
    final json = <String, dynamic>{};
    json['model'] = model;
    json['release'] = release;

    json['name'] = name;
    json['systemVersion'] = systemVersion; // iOS version
    json['machine'] = machine; //iPhone7,1

    json['sdkInt'] = sdkInt;
    json['manufacturer'] = manufacturer;
    json['product'] = product;
    json.removeWhere((key, value) => value == null);
    return json;
  }

  @override
  String toString() {
    final log = _prettyJson(jsonEncode(toJson()));
    return log;
  }

  String toShortString() {
    final log = _prettyJson(jsonEncode(toShortJson()));
    return log;
  }

  String _prettyJson(String input) => const JsonEncoder.withIndent('  ').convert(jsonDecode(input));
}
