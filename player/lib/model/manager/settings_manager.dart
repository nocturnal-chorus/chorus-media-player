import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/model/constant/StorageConstant.dart';
import 'package:player/utils/all_utils.dart';
import 'package:hive/hive.dart';
import 'package:system_theme/system_theme.dart';

class SettingsManager {
  static final SettingsManager _handleToken = SettingsManager._internal();

  factory SettingsManager() {
    return _handleToken;
  }

  SettingsManager._internal();

  final box = Hive.box(StorageConstant.SETTINGS_DATA);

  AppThemeKey? _themeKey;

  set appTheme(dynamic data) {
    _themeKey = data as AppThemeKey?;
    if (DevicesOS.isDesktop) {
      box.put(StorageConstant.THEME_KEY, data.toString());
    }
  }

  AppThemeKey get themeKey {
    _themeKey ??= getThemeEnumFromString(
        (DevicesOS.isDesktop
            ? box.get(StorageConstant.THEME_KEY)
            : AppThemeKey.system) ??
        AppThemeKey.system.name);
    return _themeKey ?? AppThemeKey.system;
  }

  AccentColor? _color;

  set color(AccentColor color) {
    _color = color;
  }

  AccentColor get color {
    _color ??= systemAccentColor;
    return _color ?? systemAccentColor;
  }

  static AccentColor get systemAccentColor {
    if ((DevicesOS.isWindows || DevicesOS.isAndroid) && !DevicesOS.isWeb) {
      return AccentColor.swatch({
        'darkest': SystemTheme.accentColor.darkest,
        'darker': SystemTheme.accentColor.darker,
        'dark': SystemTheme.accentColor.dark,
        'normal': SystemTheme.accentColor.accent,
        'light': SystemTheme.accentColor.light,
        'lighter': SystemTheme.accentColor.lighter,
        'lightest': SystemTheme.accentColor.lightest,
      });
    }
    return Colors.blue;
  }
}
