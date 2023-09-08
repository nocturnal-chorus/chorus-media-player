import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/bloc/bloc_provider.dart';
import 'package:player/ui/settings/settings_bloc.dart';
import 'package:player/widget/page.dart';

class FtSettingsPage extends StatefulWidget {
  const FtSettingsPage({super.key});

  @override
  State<FtSettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<FtSettingsPage> with PageMixin {
  final _settingsBloc = FtSettingsBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Settings page'),
      ),
      content: BlocProvider(
        bloc: _settingsBloc,
        child: Column(),
      ),
    );
  }
}
