import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:player/app/application.dart';
import 'package:player/app/application_bloc.dart';
import 'package:player/route/navigator_provider.dart';
import 'package:player/ui/demo/demo_page.dart';
import 'package:player/utils/all_utils.dart';
import 'package:window_manager/window_manager.dart';

import 'bloc/bloc_provider.dart';

const String appTitle = '虫鸣音乐';

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

class _MyHomePageState extends State<MyHomePage> {
  FtApplicationBloc? _appBloc;
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
        .where((item) => item.key != null)
        .toList()
        .indexWhere((item) => item.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
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

  //策划栏
  late final List<NavigationPaneItem> originalItems = [
    PaneItem(
      key: const ValueKey('/'),
      icon: const Icon(FluentIcons.home),
      title: const Text('虫鸣音乐'),
      body: const SizedBox.shrink(),
    ),
    PaneItemHeader(header: const Text('Empty')),
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
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
