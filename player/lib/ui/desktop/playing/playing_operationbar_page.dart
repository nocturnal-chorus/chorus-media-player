import 'package:fluent_ui/fluent_ui.dart';
import '../../../bloc/bloc_provider.dart';
import '../../../main_bloc.dart';
import '../../../widget/all_widget.dart';
import 'desktop_playing_bloc.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as ic;

class FtPlayingOperationBarPage extends StatefulWidget {
  const FtPlayingOperationBarPage({super.key});

  @override
  State<FtPlayingOperationBarPage> createState() =>
      _PlayingOperationBarPageState();
}

class _PlayingOperationBarPageState extends State<FtPlayingOperationBarPage>
    with PageMixin {
  final _detailsBloc = FtDesktopPlayingDetailsBloc();
  FtMainBloc? _mainBloc;

  @override
  void initState() {
    _mainBloc = BlocProvider.of<FtMainBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _detailsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return BlocProvider(
        bloc: _detailsBloc,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(ic.FluentIcons.heart_24_filled),
              onPressed: () => {},
            ),
            IconButton(
              icon: Icon(ic.FluentIcons.comment_20_regular),
              onPressed: () => {},
            ),
            IconButton(
              icon: Icon(ic.FluentIcons.share_24_regular),
              onPressed: () => {},
            ),
          ],
        ));
  }
}
