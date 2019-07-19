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

  String versionCode;
  String versionName;

  Future<Version> getVersions() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionCode = packageInfo.buildNumber;
    versionName = packageInfo.version;

    return Version(
      versionCode: versionCode,
      versionName: versionName
    );
  }
}