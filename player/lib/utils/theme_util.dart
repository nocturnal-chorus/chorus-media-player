import 'package:fluent_ui/fluent_ui.dart';

enum AppThemeKey { light, dark, system, custom }

class SettingsConfig {
  final AppThemeKey key;
  final AccentColor color;
  final PaneDisplayMode displayMode;

  //TODO: 添加其他设置属性
  SettingsConfig(
      {required this.color, required this.key, required this.displayMode});
}

AppThemeKey getThemeEnumFromString(String data) {
  return AppThemeKey.values.firstWhere(
    (value) => value.toString().split('.').last == data,
    orElse: () => AppThemeKey.system,
  );
}

ThemeMode getThemeMode(AppThemeKey? themeKey) {
  switch (themeKey) {
    case AppThemeKey.light:
      return ThemeMode.light;
    case AppThemeKey.dark:
      return ThemeMode.dark;
    case AppThemeKey.system:
    default:
      return ThemeMode.system;
  }
}
