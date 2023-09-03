import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../model/constant/StorageConstant.dart';
import 'devices_util.dart';

_Dispatcher logHistory = _Dispatcher("");

class _Dispatcher extends ValueNotifier<String> {
  _Dispatcher(String value) : super(value);
}

initLogger(VoidCallback runApp) async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    //add this line
    if (DevicesOS.isDesktop) {
      await windowManager.ensureInitialized();
    }
    await _initStorage();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      logError(details.stack.toString());
    };
    runApp.call();
  }, (Object error, StackTrace stack) {
    logError(stack.toString());
  });
}

_initStorage() async {
  String? appLocalPath;
  Uint8List key =
      Uint8List.fromList(utf8.encode("12345678901234567890123456789012"));
  if (!kIsWeb) {
    Directory appDir = await getApplicationSupportDirectory();
    appLocalPath = appDir.path;
    Hive.init(appLocalPath);
    // The encryption key has to be a 32 byte (256 bit) array.
    await Hive.openBox(StorageConstant.SETTINGS_DATA,
        encryptionCipher: HiveAesCipher(key));
  }
}

void log(String? value) {
  String v = value ?? "";
  logHistory.value = "$v\n${logHistory.value}";
  if (kDebugMode) {
    print(v);
  }
}

void logError(String? value) => log("[ERROR] ${value ?? ""}");
