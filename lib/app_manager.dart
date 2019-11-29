import 'package:package_info/package_info.dart';

class Version {
  final String versionCode;
  final String versionName;

  Version({
    this.versionCode,
    this.versionName
  });
}

class AppManager {
  static final AppManager _instance = AppManager._internal();
  factory AppManager() => _instance;
  AppManager._internal();

  static Future<Version> getVersions() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return Version(
      versionCode: packageInfo.buildNumber,
      versionName: packageInfo.version
    );
  }
}