import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/bloc/bloc_provider.dart';
import 'package:player/widget/page.dart';

import '../../../main_bloc.dart';
import 'desktop_home_bloc.dart';

class FtDesktopHomePage extends StatefulWidget {
  const FtDesktopHomePage({super.key});

  @override
  State<FtDesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<FtDesktopHomePage> with PageMixin {
  final _homeBloc = FtDesktopHomeBloc();
  FtMainBloc? _mainBloc;

  @override
  void initState() {
    _mainBloc = BlocProvider.of<FtMainBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Home page'),
      ),
      content: BlocProvider(
        bloc: _homeBloc,
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
