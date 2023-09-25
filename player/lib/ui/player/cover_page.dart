import 'package:fluent_ui/fluent_ui.dart';
import 'package:player/repo/entity/song_detail.dart';
import 'package:player/ui/player/cover_bloc.dart';
import '../../bloc/bloc_provider.dart';
import '../../main_bloc.dart';
import '../desktop/desktop_cover_page.dart';
import 'package:flutter/material.dart' as m;

class FtAlbumCoverPage extends StatefulWidget {
  const FtAlbumCoverPage({super.key, required this.music});

  //TODO 实体类调整
  final SongDetails music;

  @override
  State<FtAlbumCoverPage> createState() => _AlbumCoverState();
}

class _AlbumCoverState extends State<FtAlbumCoverPage>
    with TickerProviderStateMixin {
  FtMainBloc? _mainBloc;
  final _coverBloc = FtCoverBloc();

  //cover needle controller
  late AnimationController _needleController;

  //cover needle in and out animation
  late Animation<double> _needleAnimation;

  ///music change transition animation;
  AnimationController? _translateController;

  bool _needleAttachCover = false;

  bool _coverRotating = false;

  ///专辑封面X偏移量
  ///[-screenWidth/2,screenWidth/2]
  /// 0 表示当前播放音乐封面
  /// -screenWidth/2 - 0 表示向左滑动 |_coverTranslateX| 距离，即滑动显示后一首歌曲的封面
  double _coverTranslateX = 0;

  bool _beDragging = false;

  bool _previousNextDirty = true;

  ///滑动切换音乐效果上一个封面
  SongDetails? _previous;

  ///当前播放中的音乐
  SongDetails? _current;

  ///滑动切换音乐效果下一个封面
  SongDetails? _next;

  @override
  void initState() {
    _mainBloc = BlocProvider.of<FtMainBloc>(context);
    super.initState();
    _needleAttachCover = _mainBloc?.isPlaying() ?? false;
    _needleController = AnimationController(
      /*preset need position*/
      value: _needleAttachCover ? 1.0 : 0.0,
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _needleAnimation = Tween<double>(begin: -1 / 12, end: 0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_needleController);
    _current = widget.music;
    _invalidatePn();
    //TODO: 监听播放状态等
    _mainBloc?.playerStateStreamCtrl.listenStream((event) {
      _checkNeedleAndCoverStatus();
    });
  }

  Future<void> _invalidatePn() async {
    if (!_previousNextDirty) {
      return;
    }
    _previousNextDirty = false;
    //TODO 获取上一个和下一个音乐信息
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(FtAlbumCoverPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_current == widget.music) {
      _invalidatePn();
      return;
    }
    var offset = 0.0;
    if (widget.music == _previous) {
      offset = MediaQuery.of(context).size.width;
    } else if (widget.music == _next) {
      offset = -MediaQuery.of(context).size.width;
    }
    _animateCoverTranslateTo(
      offset,
      onCompleted: () {
        setState(() {
          _coverTranslateX = 0;
          _current = widget.music;
          _previousNextDirty = true;
          _invalidatePn();
          _checkNeedleAndCoverStatus();
        });
      },
    );
  }

  @override
  void dispose() {
    _needleController.dispose();
    _translateController?.dispose();
    _translateController = null;
    super.dispose();
  }

  static const double kHeightSpaceAlbumTop = 100;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _coverBloc,
      child: LayoutBuilder(
        builder: (context, constraints) {
          assert(
            constraints.maxWidth.isFinite,
            'the width of cover layout should be constrained!',
          );
          return ClipRect(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _build(context, constraints.maxWidth),
            ),
          );
        },
      ),
    );
  }

  Widget _build(BuildContext context, double layoutWidth) {
    final theme = FluentTheme.of(context);
    return Stack(
      children: <Widget>[
        GestureDetector(
          onHorizontalDragStart: (detail) {
            _beDragging = true;
            _checkNeedleAndCoverStatus();
          },
          onHorizontalDragUpdate: (detail) {
            if (_beDragging) {
              setState(() {
                _coverTranslateX += detail.primaryDelta!;
              });
            }
          },
          onHorizontalDragEnd: (detail) {
            _beDragging = false;

            //左右切换封面滚动速度阈值
            final vThreshold =
                1.0 / (0.050 * MediaQuery.of(context).devicePixelRatio);

            final sameDirection =
                (_coverTranslateX > 0 && detail.primaryVelocity! > 0) ||
                    (_coverTranslateX < 0 && detail.primaryVelocity! < 0);
            if (_coverTranslateX.abs() > layoutWidth / 2 ||
                (sameDirection && detail.primaryVelocity!.abs() > vThreshold)) {
              var des = MediaQuery.of(context).size.width;
              if (_coverTranslateX < 0) {
                des = -des;
              }
              _animateCoverTranslateTo(
                des,
                onCompleted: () {
                  setState(() {
                    //reset translateX to 0 when animation complete
                    _coverTranslateX = 0;
                    if (des > 0) {
                      _current = _previous;
                      _mainBloc?.onPreviousSongButtonPressed();
                    } else {
                      _current = _next;
                      _mainBloc?.onNextSongButtonPressed();
                    }
                    _previousNextDirty = true;
                  });
                },
              );
            } else {
              //animate [_coverTranslateX] to 0
              _animateCoverTranslateTo(
                0,
                onCompleted: _checkNeedleAndCoverStatus,
              );
            }
          },
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.only(
              left: 64,
              right: 64,
              top: kHeightSpaceAlbumTop,
            ),
            child: Stack(
              children: <Widget>[
                Transform.scale(
                  scale: 1.035,
                  child: const AspectRatio(
                    aspectRatio: 1,
                    child: ClipOval(
                      //TODO: 颜色适配
                      child: ColoredBox(
                        color: m.Colors.white10,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(_coverTranslateX - layoutWidth, 0),
                  child:
                      FtRotationCoverImage(rotating: false, music: _previous),
                ),
                Transform.translate(
                  offset: Offset(_coverTranslateX, 0),
                  child: FtRotationCoverImage(
                    rotating: _coverRotating && !_beDragging,
                    music: _current,
                  ),
                ),
                Transform.translate(
                  offset: Offset(_coverTranslateX + layoutWidth, 0),
                  child: FtRotationCoverImage(rotating: false, music: _next),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: const Offset(40, -15),
              child: RotationTransition(
                turns: _needleAnimation,
                alignment:
                    //44,37 是针尾的圆形的中心点像素坐标, 273,402是playing_page_needle.png的宽高
                    //所以对此计算旋转中心点的偏移,以保重旋转动画的中心在针尾圆形的中点
                    const Alignment(-1 + 44 * 2 / 273, -1 + 37 * 2 / 402),
                child: Image.asset(
                  'assets/images/playing_desktop_needle.webp',
                  height: kHeightSpaceAlbumTop * 1.8,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void _animateCoverTranslateTo(double des, {void Function()? onCompleted}) {
    _translateController?.dispose();
    _translateController = null;
    _translateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final animation =
        Tween(begin: _coverTranslateX, end: des).animate(_translateController!);
    animation.addListener(() {
      setState(() {
        _coverTranslateX = animation.value;
      });
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _translateController?.dispose();
        _translateController = null;
        if (onCompleted != null) {
          onCompleted();
        }
      }
    });
    _translateController!.forward();
  }

  void _checkNeedleAndCoverStatus() {
    // needle is should attach to cover
    final attachToCover = (_mainBloc?.isPlaying() ?? false) &&
        !_beDragging &&
        _translateController == null;
    _rotateNeedle(attachToCover);

    //handle album cover animation
    setState(() {
      _coverRotating = (_mainBloc?.isPlaying() ?? false) && _needleAttachCover;
    });
  }

  ///rotate needle to (un)attach to cover image
  void _rotateNeedle(bool attachToCover) {
    if (_needleAttachCover == attachToCover) {
      return;
    }
    _needleAttachCover = attachToCover;
    if (attachToCover) {
      _needleController.forward(from: _needleController.value);
    } else {
      _needleController.reverse(from: _needleController.value);
    }
  }
}
