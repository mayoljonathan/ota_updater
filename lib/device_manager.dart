import 'dart:io' show Platform;
import 'package:device_info/device_info.dart';

class DeviceManager {
  static final DeviceManager _instance = DeviceManager._internal();
  factory DeviceManager() => _instance;
  DeviceManager._internal();

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      var info = {
        "version": {
          "baseOS": androidInfo.version.baseOS,
          "codename": androidInfo.version.codename,
          "incremental": androidInfo.version.incremental,
          "previewSdkInt": androidInfo.version.previewSdkInt,
          "release": androidInfo.version.release,
          "sdkInt": androidInfo.version.sdkInt,
          "securityPatch": androidInfo.version.securityPatch,
        },
        "board": androidInfo.board,
        "bootloader": androidInfo.bootloader,
        "brand": androidInfo.brand,
        "device": androidInfo.device,
        "display": androidInfo.display,
        "fingerprint": androidInfo.fingerprint,
        "hardware": androidInfo.hardware,
        "host": androidInfo.host,
        "id": androidInfo.id,
        "manufacturer": androidInfo.manufacturer,
        "model": androidInfo.model,
        "product": androidInfo.product,
        "supported32BitAbis": androidInfo.supported32BitAbis,
        "supported64BitAbis": androidInfo.supported64BitAbis,
        "supportedAbis":androidInfo.supportedAbis,
        "tags": androidInfo.tags,
        "type": androidInfo.type,
        "isPhysicalDevice" : androidInfo.isPhysicalDevice,
        "androidId": androidInfo.androidId,
      };
      return info;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      var info = {
        "name": iosInfo.name,
        "systemName": iosInfo.systemName,
        "systemVersion": iosInfo.systemVersion,
        "model": iosInfo.model,
        "localizedModel": iosInfo.localizedModel,
        "identifierForVendor": iosInfo.identifierForVendor,
        "isPhysicalDevice": iosInfo.isPhysicalDevice,
        "utsname": {
          "machine": iosInfo.utsname.machine,
          "machine": iosInfo.utsname.nodename,
          "machine": iosInfo.utsname.release,
          "machine": iosInfo.utsname.sysname,
          "machine": iosInfo.utsname.version,
        }
      };
      return info;
    }
    return null;
  }

}