import 'package:extended_image/extended_image.dart';
import 'package:player/utils/all_utils.dart';
import 'package:player/widget/all_widget.dart';
import '../bloc/bloc_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/main_bloc.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart'
    as progress;

enum ButtonState { paused, playing, loading }

class FtBottomPlayerPage extends StatefulWidget {
  /// safe area.
  final double bottomExtraPadding;

  const FtBottomPlayerPage({super.key, this.bottomExtraPadding = 0});

  @override
  State<FtBottomPlayerPage> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<FtBottomPlayerPage> {
  FtMainBloc? _mainBloc;

  @override
  void initState() {
    _mainBloc = BlocProvider.of<FtMainBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: BlocProvider(
        bloc: _mainBloc,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.bottomExtraPadding),
                  child: Row(
                    children: [
                      Expanded(child: _playingItem()),
                      SizedBox(
                        width: 20,
                      ),
                      _centerController(),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: _progressBar()),
          ],
        ),
      ),
    );
  }

  Widget _playingItem() {
    return GestureDetector(
      onTap: () {
        //TODO: 歌曲详情
      },
      child: StreamBuilder(
        stream: _mainBloc?.currentSongDetailsStreamCtrl.stream,
        builder: (ctx, snapData) {
          final songDetails = snapData.data;
          if (songDetails == null) {
            return const SizedBox();
          } else {
            return Row(
              children: [
                const SizedBox(width: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: DevicesOS.isWeb
                      ? ExtendedImage.network(
                          songDetails.avatar ?? "",
                          cache: true,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : AppImage(
                          url: songDetails.avatar,
                          width: 48,
                          height: 48,
                        ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        songDetails.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "display",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _centerController() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: _mainBloc?.isFirstSongStreamCtrl.stream,
              builder: (context, snapData) {
                return IconButton(
                  icon: const Icon(FluentIcons.previous),
                  onPressed: () {
                    (snapData.data == true)
                        ? null
                        : _mainBloc?.onPreviousSongButtonPressed();
                  },
                );
              },
            ),
            const SizedBox(width: 20),
            StreamBuilder(
              stream: _mainBloc!.playerStateStreamCtrl.stream,
              builder: (context, snapData) {
                switch (snapData.data) {
                  case ButtonState.loading:
                    return Container(
                      width: 24,
                      height: 24,
                      child: const ProgressRing(),
                    );
                  case ButtonState.paused:
                    return IconButton(
                      icon: const Icon(FluentIcons.play),
                      onPressed: () {
                        _mainBloc?.play();
                      },
                    );
                  case ButtonState.playing:
                    return IconButton(
                      icon: const Icon(FluentIcons.pause),
                      onPressed: () {
                        _mainBloc?.pause();
                      },
                    );
                  default:
                    return Container(
                      width: 24,
                      height: 24,
                      child: const ProgressRing(),
                    );
                }
              },
            ),
            const SizedBox(width: 20),
            StreamBuilder(
              stream: _mainBloc?.isLastSongStreamCtrl.stream,
              builder: (context, snapData) {
                return IconButton(
                  icon: const Icon(FluentIcons.next),
                  onPressed: () {
                    (snapData.data == true)
                        ? null
                        : _mainBloc?.onNextSongButtonPressed();
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _progressBar() {
    return StreamBuilder(
      stream: _mainBloc?.progressStreamCtrl.stream,
      builder: (ctx, snapData) {
        final progressData = snapData.data;
        if (progressData == null) {
          return const SizedBox.shrink();
        } else {
          return SizedBox(
            height: 20,
            child: progress.ProgressBar(
              progress: progressData.current,
              buffered: progressData.buffered,
              total: progressData.total,
              onSeek: (duration) {
                _mainBloc?.seek(duration);
              },
            ),
          );
        }
      },
    );
  }
}
