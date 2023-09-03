import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

_Dispatcher logHistory = _Dispatcher("");

class _Dispatcher extends ValueNotifier<String> {
  _Dispatcher(String value) : super(value);
}

initLogger(VoidCallback runApp) async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    //add this line
    await windowManager.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      logError(details.stack.toString());
    };
    runApp.call();
  }, (Object error, StackTrace stack) {
    logError(stack.toString());
  });
}

void log(String? value) {
  String v = value ?? "";
  logHistory.value = "$v\n${logHistory.value}";
  if (kDebugMode) {
    print(v);
  }
}

void logError(String? value) => log("[ERROR] ${value ?? ""}");
