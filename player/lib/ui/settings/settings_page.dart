import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/bloc/bloc_provider.dart';
import 'package:player/model/manager/settings_manager.dart';
import 'package:player/ui/settings/settings_bloc.dart';
import 'package:player/widget/page.dart';
import 'package:player/utils/all_utils.dart';

import '../../app/application_bloc.dart';

class FtSettingsPage extends StatefulWidget {
  const FtSettingsPage({super.key});

  @override
  State<FtSettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<FtSettingsPage> with PageMixin {
  final _settingsBloc = FtSettingsBloc();
  FtApplicationBloc? _appBloc;

  @override
  void initState() {
    _appBloc = BlocProvider.of<FtApplicationBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    const spacer = SizedBox(height: 10.0);
    const biggerSpacer = SizedBox(height: 40.0);
    //TODO: 界面调整
    return BlocProvider(
      bloc: _settingsBloc,
      child: ScaffoldPage.scrollable(
        header: PageHeader(
          title: const Text('Settings page'),
        ),
        children: [
          Text('Theme mode',
              style: FluentTheme.of(context).typography.subtitle),
          spacer,
          ...List.generate(ThemeMode.values.length, (index) {
            final mode = ThemeMode.values[index];
            return Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 8.0),
              child: RadioButton(
                checked: getThemeMode(SettingsManager().themeKey) == mode,
                onChanged: (value) {
                  if (value) {
                    _appBloc?.refreshAppTheme(getThemeKeyByMode(mode));
                    //TODO: 界面效果
                  }
                },
                content: Text('$mode'.replaceAll('ThemeMode.', '')),
              ),
            );
          }),
          biggerSpacer,
        ],
      ),
    );
  }
}
