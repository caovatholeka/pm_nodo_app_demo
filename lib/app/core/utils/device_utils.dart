import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceUtils {
  static Future<String?> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if(Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.id;
    }

    if(Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor;
    }

    return null;
  }
}