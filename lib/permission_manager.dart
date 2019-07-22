import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  Future<Map<PermissionGroup, PermissionStatus>> requestPermissions(List<PermissionGroup> permissionsToRequest) async {
    return await PermissionHandler().requestPermissions(permissionsToRequest);
  }
}