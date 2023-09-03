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
    refreshAppSettingsController.add(SettingsConfig(
        color: color, key: themeKey, displayMode: getNavigationDisplayMode()));
  }

  //获取导航栏Align
  //TODO 判断页面宽度调整
  PaneDisplayMode getNavigationDisplayMode() {
    if (DevicesOS.isWeb) {
      return PaneDisplayMode.top;
    } else if (DevicesOS.isDesktop) {
      return PaneDisplayMode.auto;
    } else if (DevicesOS.isMobile) {
      return PaneDisplayMode.minimal;
    }
    return PaneDisplayMode.auto;
  }

  //改变系统主题
  void refreshAppTheme(AppThemeKey themeKey) {
    SettingsManager().appTheme = themeKey;
    final oldData = refreshAppSettingsController.value;
    refreshAppSettingsController.add(SettingsConfig(
        color: oldData?.color ?? SettingsManager().color,
        key: themeKey,
        displayMode: oldData?.displayMode ?? getNavigationDisplayMode()));
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
