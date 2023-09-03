import 'package:flutter/foundation.dart';
import 'package:universal_platform/universal_platform.dart';

class DevicesOS {
  static bool isIOS = UniversalPlatform.isIOS;
  static bool isAndroid = UniversalPlatform.isAndroid;
  static bool isMacOS = UniversalPlatform.isMacOS;
  static bool isWindows = UniversalPlatform.isWindows;
  static bool isLinux = UniversalPlatform.isLinux;

  static bool isWeb = kIsWeb;

  static bool get isDesktop => isWindows || isMacOS || isLinux;

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktopOrWeb => isDesktop || isWeb;

  static bool get isMobileOrWeb => isMobile || isWeb;
}
