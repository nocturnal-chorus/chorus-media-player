import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/bloc/bloc_provider.dart';
import 'package:player/ui/demo/demo_bloc.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart'
as progress;
import 'package:player/widget/page.dart';
import 'package:player/ui/bottom_player_page.dart' as demo;

import '../../main_bloc.dart';

class FtDemoPage extends StatefulWidget {
  const FtDemoPage({super.key});

  @override
  State<FtDemoPage> createState() => _DemoPageState();
}

@Deprecated('remove')
class _DemoPageState extends State<FtDemoPage> with PageMixin {
  final _demoBloc = FtDemoBloc();
  FtMainBloc? _mainBloc;

  @override
  void initState() {
    _mainBloc = BlocProvider.of<FtMainBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _demoBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    //return ScaffoldPage();
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: const Text('Demo music playing'),
      ),
      content: BlocProvider(
        bloc: _demoBloc,
        child: Column(
          children: [
            StreamBuilder(
              stream: _demoBloc.currentSongTitleStreamCtrl.stream,
              builder: (context, snapData) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(snapData.data ?? ""),
                );
              },
            ),
            StreamBuilder(
              stream: _demoBloc.progressStreamCtrl.stream,
              builder: (context, snapData) {
                return progress.ProgressBar(
                  progress: snapData.data?.current ?? Duration(seconds: 0),
                  buffered: snapData.data?.buffered ?? Duration(seconds: 0),
                  total: snapData.data?.total ?? Duration(seconds: 0),
                  onSeek: (duration) {
                    _demoBloc.seek(duration);
                  },
                );
              },
            ),
            Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StreamBuilder(
                    stream: _demoBloc.isFirstSongStreamCtrl.stream,
                    builder: (context, snapData) {
                      return IconButton(
                        icon: const Icon(FluentIcons.previous),
                        onPressed: () {
                          (snapData.data == true)
                              ? null
                              : _demoBloc.onPreviousSongButtonPressed();
                        },
                      );
                    },
                  ),
                  //playOrPause
                  StreamBuilder(
                    stream: _demoBloc.playerStateStreamCtrl.stream,
                    builder: (context, snapData) {
                      switch (snapData.data) {
                        case demo.PlayerButtonState.loading:
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 32.0,
                            height: 32.0,
                            child: const ProgressRing(),
                          );
                        case demo.PlayerButtonState.paused:
                          return IconButton(
                            icon: const Icon(FluentIcons.play),
                            onPressed: () {
                              _demoBloc.play();
                            },
                          );
                        case demo.PlayerButtonState.playing:
                          return IconButton(
                            icon: const Icon(FluentIcons.pause),
                            onPressed: () {
                              _demoBloc.pause();
                            },
                          );
                        default:
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 32.0,
                            height: 32.0,
                            child: const ProgressRing(),
                          );
                      }
                    },
                  ),
                  StreamBuilder(
                    stream: _demoBloc.isLastSongStreamCtrl.stream,
                    builder: (context, snapData) {
                      return IconButton(
                        icon: const Icon(FluentIcons.next),
                        onPressed: () {
                          (snapData.data == true)
                              ? null
                              : _demoBloc.onNextSongButtonPressed();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: kOneLineTileHeight,
            ),
          ],
        ),
      ),
    );
  }
}
