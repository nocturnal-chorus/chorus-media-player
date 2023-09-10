import 'package:flutter/material.dart';

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
              child: Material(
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.bottomExtraPadding),
                  child: Row(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
