import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  static Future<PermissionStatus> checkPermission(PermissionGroup permissionGroup) {
    return PermissionHandler().checkPermissionStatus(permissionGroup);
  }

  static Future<Map<PermissionGroup, PermissionStatus>> requestPermissions(List<PermissionGroup> permissionsToRequest) {
    return PermissionHandler().requestPermissions(permissionsToRequest);
  }

  /// Returns true, previously rejected the permission and trying to access the feature again 
  /// Returns false, if: 
  /// 1. User has press 'dont ask again' (Android only)
  /// 2. If the device policy prohibits the app from having that permission
  /// 3. If we call this method very first time before asking permission.
  static Future<bool> canRequestDialogShow(PermissionGroup permission) {
    return PermissionHandler().shouldShowRequestPermissionRationale(permission);
  }

  static Future<bool> openAppSettings() {
    return PermissionHandler().openAppSettings();
  }
}