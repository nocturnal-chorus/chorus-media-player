import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:player/app/application.dart';
import 'package:player/app/application_bloc.dart';
import 'package:player/main_bloc.dart';
import 'package:player/route/navigator_provider.dart';
import 'package:player/ui/bottom_player_page.dart';
import 'package:player/ui/demo/demo_page.dart';
import 'package:player/ui/settings/settings_page.dart';
import 'package:player/utils/all_utils.dart';
import 'package:window_manager/window_manager.dart';

import 'bloc/bloc_provider.dart';
T? ambiguate<T>(T? value) => value;

Future<void> main() async {
  //init logger and third library
  await initLogger(() async {
    runApp(const FtApplication());
  });
}

final _shellNavigatorKey = GlobalKey<NavigatorState>();
const String rememberId = 'ChorusPlayer';
final router = GoRouter(navigatorKey: NavigatorProvider.navigatorKey, routes: [
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    restorationScopeId: rememberId,
    builder: (context, state, child) {
      return MyHomePage(
        shellContext: _shellNavigatorKey.currentContext,
        child: child,
      );
    },
    //TODO: 首页
    routes: [
      /// Home
      GoRoute(path: '/', builder: (context, state) => const FtDemoPage()),
      GoRoute(
          path: '/settings',
          builder: (context, state) => const FtSettingsPage()),
    ],
  ),
]);

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.child,
    required this.shellContext,
  });

  final Widget child;
  final BuildContext? shellContext;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  FtApplicationBloc? _appBloc;
  final _mainBloc = FtMainBloc();
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
            .where((item) => item.key != null)
            .toList()
            .indexWhere((item) => item.key == Key(location)) +
        1;

    //TODO: index error
    if (indexOriginal == 0) {
      int indexFooter = footerItems
              .where((element) => element.key != null)
              .toList()
              .indexWhere((element) => element.key == Key(location)) +
          1;
      if (indexFooter == 0) {
        return 1;
      }
      return originalItems
              .where((element) => element.key != null)
              .toList()
              .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }

  NavigationPaneItem _header() {
    if (DevicesOS.isDesktop) {
      return PaneItemAction(
        icon: Icon(FluentIcons.app_icon_default),
        onTap: () {},
        title: Text(appTitle),
        autofocus: false,
      );
      return PaneItemHeader(
          header: Row(
        children: [
          Icon(FluentIcons.app_icon_default),
          SizedBox.shrink(),
          Text(appTitle)
        ],
      ));
    }
    if (DevicesOS.isWeb) {
      return PaneItemAction(
        icon: Icon(FluentIcons.app_icon_default),
        onTap: () {},
        title: Text(appTitle),
        autofocus: false,
      );
    }
    if (DevicesOS.isMobile) {
      //TODO: 用户头像信息展示
      return PaneItemHeader(
          header: Row(
        children: [
          Icon(FluentIcons.app_icon_default),
          SizedBox.shrink(),
          Text(appTitle)
        ],
      ));
    }
    return PaneItemHeader(
        header: Row(
      children: [
        Icon(FluentIcons.app_icon_default),
        SizedBox.shrink(),
        Text(appTitle)
      ],
    ));
  }

  //侧滑栏
  late final List<NavigationPaneItem> originalItems = [
    _header(),
    PaneItem(
      key: const ValueKey('/'),
      icon: const Icon(FluentIcons.search_and_apps),
      title: const Text('发现音乐'),
      body: const SizedBox.shrink(),
    ),
  ].map((e) {
    if (e is PaneItem) {
      return PaneItem(
        key: e.key,
        icon: e.icon,
        title: e.title,
        body: e.body,
        onTap: () {
          final path = (e.key as ValueKey).value;
          if (GoRouterState.of(context).uri.toString() != path) {
            context.go(path);
          }
          e.onTap?.call();
        },
      );
    }
    return e;
  }).toList();

  //底部菜单栏
  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey('/settings'),
      icon: const Icon(FluentIcons.settings),
      title: const Text('Settings'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != '/settings') {
          context.go('/settings');
        }
      },
    ),
  ];

  @override
  void initState() {
    _appBloc = BlocProvider.of<FtApplicationBloc>(context);
    _mainBloc.initial();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _mainBloc.dispose();
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _mainBloc.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      bloc: _mainBloc,
      child: ScaffoldPage(
        padding: EdgeInsets.only(top: 0.0),
        content: NavigationView(
          key: viewKey,
          appBar: NavigationAppBar(
            automaticallyImplyLeading: false,
            height: DevicesOS.isWeb ? 0 : 50,
            leading: () {
              return const SizedBox.shrink();
            }(),
            title: () {
              if (DevicesOS.isWeb) {
                return const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(appTitle),
                );
              }
              return const DragToMoveArea(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(appTitle),
                ),
              );
            }(),
            actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (DevicesOS.isDesktop) const WindowButtons(),
            ]),
          ),
          paneBodyBuilder: (item, child) {
            final name =
                item?.key is ValueKey ? (item!.key as ValueKey).value : null;
            return FocusTraversalGroup(
              key: ValueKey('body$name'),
              child: widget.child,
            );
          },
          pane: NavigationPane(
            selected: _calculateSelectedIndex(context),
            header: SizedBox(
              height: kOneLineTileHeight,
              child: SizedBox.shrink(),
            ),
            displayMode:
                _appBloc?.getNavigationDisplayMode() ?? PaneDisplayMode.auto,
            items: originalItems,
            autoSuggestBoxReplacement: const Icon(FluentIcons.search),
            footerItems: footerItems,
          ),
        ),
        //TODO: 移动端隐藏
        bottomBar: Container(
          color: theme.activeColor,
          width: size.width,
          child: FtBottomPlayerPage(),
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
