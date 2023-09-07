import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/app/application_bloc.dart';
import 'package:player/bloc/bloc_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../main.dart';
import '../utils/all_utils.dart';

class FtApplication extends StatefulWidget {
  const FtApplication({super.key});

  @override
  State<FtApplication> createState() => _FtApplicationState();
}

class _FtApplicationState extends State<FtApplication> with WindowListener {
  final _appBloc = FtApplicationBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _appBloc,
      child: StreamBuilder(
        initialData: null,
        stream: _appBloc.refreshAppSettingsController.stream,
        builder: (context, snapData) {
          return _appWidget(snapData.data);
        },
      ),
    );
  }

  Widget _appWidget(SettingsConfig? settings) {
    //TODO: 多语言支持
    return FluentApp.router(
      title: appTitle,
      //locale: _locale,
      debugShowCheckedModeBanner: false,
      themeMode: getThemeMode(settings?.key),
      color: settings?.color,
      theme: FluentThemeData(
        accentColor: settings?.color,
        //scaffoldBackgroundColor: settings?.color.normal,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      darkTheme: FluentThemeData(
          accentColor: settings?.color,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          )),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: NavigationPaneTheme(
            data: NavigationPaneThemeData(
              backgroundColor: null,
            ),
            child: child!,
          ),
        );
      },
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }

  @override
  void onWindowClose() {
    //TODO: 桌面端关闭
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _appBloc.initial();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}
