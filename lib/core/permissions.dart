import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;

    if (build.version.sdkInt >= 30) {
      var status = await Permission.manageExternalStorage.request();
      return status.isGranted; // ✅ Return true if granted, false if not
    } else {
      var status = await Permission.storage.request();
      return status.isGranted; // ✅ Return true if granted, false if not
    }
  }
}
