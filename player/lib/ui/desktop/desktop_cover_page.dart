import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:player/repo/entity/song_detail.dart';
import 'package:player/widget/all_widget.dart';
import '../../utils/devices_util.dart';

class FtDesktopCoverPage extends StatefulWidget {
  @override
  State<FtDesktopCoverPage> createState() => _DesktopCoverPageState();
}

class _DesktopCoverPageState extends State<FtDesktopCoverPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class FtRotationCoverImage extends StatefulWidget {
  const FtRotationCoverImage({
    super.key,
    required this.rotating,
    required this.music,
  });

  final bool rotating;
  final SongDetails? music;

  @override
  State<FtRotationCoverImage> createState() => _RotationCoverImageState();
}

class _RotationCoverImageState extends State<FtRotationCoverImage>
    with SingleTickerProviderStateMixin {
  //album cover rotation
  double rotation = 0;

  //album cover rotation animation
  late AnimationController controller;

  @override
  void didUpdateWidget(FtRotationCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rotating) {
      controller.forward(from: controller.value);
    } else {
      controller.stop();
    }
    if (widget.music != oldWidget.music) {
      controller.value = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )
      ..addListener(() {
        setState(() {
          rotation = controller.value * 2 * pi;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && controller.value == 1) {
          controller.forward(from: 0);
        }
      });
    if (widget.rotating) {
      controller.forward(from: controller.value);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (widget.music == null || widget.music!.avatar == null) {
      image = Image.asset(
        'assets/images/playing_desktop_disc.png',
        fit: BoxFit.cover,
      );
    } else {
      if (DevicesOS.isWeb) {
        image = ExtendedImage.network(
          widget.music!.avatar ?? "",
          cache: true,
          fit: BoxFit.cover,
        );
      } else {
        image = AppImage(
          url: widget.music!.avatar,
        );
      }
    }
    return Transform.rotate(
      angle: rotation,
      child: m.Material(
        elevation: 3,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(500),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            foregroundDecoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/playing_desktop_disc.png'),
              ),
            ),
            padding: const EdgeInsets.all(30),
            child: ClipOval(child: image),
          ),
        ),
      ),
    );
  }
}
