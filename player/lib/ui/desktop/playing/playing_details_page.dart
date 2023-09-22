import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/ui/player/cover_page.dart';
import '../../../bloc/bloc_provider.dart';
import '../../../main_bloc.dart';
import '../../../widget/all_widget.dart';
import 'desktop_playing_bloc.dart';

class FtDesktopPlayingDetailsPage extends StatefulWidget {
  const FtDesktopPlayingDetailsPage({super.key});

  @override
  State<FtDesktopPlayingDetailsPage> createState() =>
      _DesktopPlayingDetailsPageState();
}

class _DesktopPlayingDetailsPageState extends State<FtDesktopPlayingDetailsPage>
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
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Playing Details page'),
      ),
      content: BlocProvider(
        bloc: _detailsBloc,
        child: Row(
          children: [
            Flexible(
              child: _layoutCover(),
              flex: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _layoutCover() {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: StreamBuilder(
        stream: _mainBloc?.currentSongDetailsStreamCtrl.stream,
        builder: (ctx, snapData) {
          final currentSong = _mainBloc?.currentSongDetailsStreamCtrl.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: IgnorePointer(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: currentSong == null
                        ? SizedBox()
                        : FtAlbumCoverPage(music: currentSong),
                  ),
                ),
              ),
              const Spacer(),
            ],
          );
        },
      ),
    );
  }
}
