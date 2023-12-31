import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:player/utils/all_utils.dart';
import 'package:player/widget/all_widget.dart';
import '../bloc/bloc_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/main_bloc.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as ic;
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart'
    as progress;

enum PlayerButtonState { paused, playing, loading }

//TODO: 播放模式
enum RepeatMode {
  shuffle,
  single,
  sequence,
  off,
}

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
                      Expanded(
                        child: _playingItem(),
                        flex: 2,
                      ),
                      Expanded(
                        child: _centerController(),
                        flex: 5,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _playerControl(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playingItem() {
    return GestureDetector(
      onTap: () {
        //TODO: 歌曲详情
        context.go('/desktop/playingDetails');
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: _mainBloc?.isFirstSongStreamCtrl.stream,
              builder: (context, snapData) {
                return IconButton(
                  icon: const Icon(ic.FluentIcons.previous_16_filled),
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
                  case PlayerButtonState.loading:
                    return Container(
                      width: 24,
                      height: 24,
                      child: const ProgressRing(),
                    );
                  case PlayerButtonState.paused:
                    return IconButton(
                      icon: const Icon(ic.FluentIcons.play_20_filled),
                      onPressed: () {
                        _mainBloc?.play();
                      },
                    );
                  case PlayerButtonState.playing:
                    return IconButton(
                      icon: const Icon(ic.FluentIcons.pause_16_filled),
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
                  icon: const Icon(ic.FluentIcons.next_20_filled),
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
        _progressBar(),
      ],
    );
  }

  Widget _playerControl() {
    return Row(
      children: [
        const Spacer(),
        //TODO: Like button
        const SizedBox(width: 10),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: _playerRepeatModeIconButton(),
        ),
        //TODO: 播放列表
        _playingListButton(),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: _volumeControl(),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _playerRepeatModeIconButton() {
    //TODO: 播放模式调整
    return StreamBuilder(
      stream: _mainBloc?.repeatStateStreamCtrl.stream,
      builder: (ctx, snapData) {
        final mode = snapData.data;
        final String text;
        final IconData icon;
        switch (mode) {
          case LoopMode.off:
            text = "顺序";
            icon = ic.FluentIcons.arrow_repeat_all_20_regular;
            break;
          case LoopMode.one:
            text = "单曲循环";
            icon = ic.FluentIcons.arrow_repeat_1_20_regular;
            break;
          case LoopMode.all:
            text = "循环";
            icon = ic.FluentIcons.arrow_repeat_all_20_regular;
            break;
          default:
            text = "顺序";
            icon = ic.FluentIcons.arrow_repeat_all_20_regular;
            break;
        }
        return Tooltip(
          message: text,
          useMousePosition: false,
          triggerMode: TooltipTriggerMode.tap,
          style: const TooltipThemeData(
            preferBelow: true,
            waitDuration: Duration(),
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: () {
              _mainBloc?.onRepeatButtonPressed();
            },
          ),
        );
      },
    );
  }

  Widget _playingListButton() {
    return SizedBox();
  }

  Widget _volumeControl() {
    final theme = FluentTheme.of(context);
    return StreamBuilder(
      stream: _mainBloc?.volumeStreamCtrl.stream,
      builder: (ctx, snap) {
        final volume = snap.data ?? 0.0;
        final isMuted = volume <= 0.0001;
        IconData icon;
        if (isMuted) {
          icon = ic.FluentIcons.speaker_off_16_regular;
        } else if (volume <= 0.2) {
          icon = ic.FluentIcons.speaker_0_16_regular;
        } else if (volume <= 0.5) {
          icon = ic.FluentIcons.speaker_1_16_regular;
        } else {
          icon = ic.FluentIcons.speaker_2_16_regular;
        }
        return HoverOverlay(
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          overlayBuilder: (context, progress) {
            //TODO: 优化滑块平滑性
            return Opacity(
              opacity: progress,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: m.Material(
                  color: theme.cardColor,
                  elevation: 10,
                  shadowColor: theme.shadowColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: SizedBox(
                      child: Slider(
                          vertical: true,
                          value: (volume * 100).clamp(0.0, 100.0),
                          onChanged: (value) {
                            _mainBloc?.setVolume(value / 100);
                          }),
                    ),
                  ),
                ),
              ),
            );
          },
          child: IconButton(
            icon: Icon(icon),
            onPressed: () {},
          ),
        );
      },
    );
  }

  Widget _progressBar() {
    final theme = FluentTheme.of(context);
    //TODO: progress样式调整
    final progressStyle = SliderTheme.of(context);
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
              barHeight: 4.5,
              baseBarColor: theme.inactiveColor,
              thumbRadius: 8,
              thumbGlowRadius: 16,
              timeLabelLocation: progress.TimeLabelLocation.sides,
              progressBarColor:
              theme.accentColor.defaultBrushFor(theme.brightness),
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
