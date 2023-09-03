import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/bloc/bloc_provider.dart';

import '../model/manager/settings_manager.dart';
import '../utils/all_utils.dart';

class FtApplicationBloc extends BlocBase {
  final refreshAppThemeController =
      BlocStreamController<AppThemeKey>(isBroadcast: false);
  final refreshAppSettingsController =
      BlocStreamController<SettingsConfig?>(isBroadcast: false);

  initial() {
    getAppSettings();
  }

  getAppSettings() async {
    AppThemeKey themeKey = SettingsManager().themeKey;
    AccentColor color = SettingsManager().color;
    refreshAppSettingsController
        .add(SettingsConfig(color: color, key: themeKey));
  }

  //改变系统主题
  void refreshAppTheme(AppThemeKey themeKey) {
    SettingsManager().appTheme = themeKey;
    final oldData = refreshAppSettingsController.value;
    refreshAppSettingsController.add(SettingsConfig(
        color: oldData?.color ?? SettingsManager().color, key: themeKey));
  }

  ThemeMode getCurrentTheme() {
    switch (refreshAppThemeController.value) {
      case AppThemeKey.light:
        return ThemeMode.light;
      case AppThemeKey.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  void dispose() {
    refreshAppThemeController.close();
    refreshAppSettingsController.close();
  }
}
