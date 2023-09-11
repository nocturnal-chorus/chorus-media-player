import 'package:flutter/material.dart';

class ShimmerAnimator extends StatefulWidget {
  const ShimmerAnimator({
    super.key,
    this.child,
    this.highlightColor,
    required this.opacity,
    this.baseColor,
    this.duration,
    this.interval,
    this.direction,
    this.radius,
  });

  final Color? highlightColor;
  final Color? baseColor;
  final Duration? duration;
  final Duration? interval;
  final double? radius;
  final ShimmerDirection? direction;
  final Widget? child;
  final double opacity;

  @override
  State<StatefulWidget> createState() => _ShimmerAnimatorState();
}

//Animator state controls the animation using all the parameters defined
class _ShimmerAnimatorState extends State<ShimmerAnimator>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0, 0.6, curve: Curves.decelerate),
    ))
      ..addListener(() async {
        if (controller.isCompleted)
          Future.delayed(widget.interval!, () {
            if (mounted) {
              controller.repeat();
            }
          });
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: CustomSplashAnimation(
        context: context,
        position: animation.value,
        highlightColor: widget.highlightColor,
        baseColor: widget.baseColor,
        begin: widget.direction!.begin,
        end: widget.direction!.end,
        radius: widget.radius,
        opacity: widget.opacity,
      ),
      child: widget.child,
    );
  }
}

class CustomSplashAnimation extends CustomPainter {
  CustomSplashAnimation({
    this.context,
    this.position,
    this.highlightColor,
    this.baseColor,
    required this.opacity,
    this.begin,
    this.end,
    this.radius,
  });

  final double? radius;
  final double opacity;
  final BuildContext? context;
  double? position;
  double width = 0.2;
  final Color? highlightColor;
  final Color? baseColor;
  final Alignment? begin, end;

  //Custom Painter to paint one frame of the animation. This is called in a loop to animate
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    final stops = [
      0.0,
      position!,
      (position! + width) > 1 ? 1.0 : position! + width,
      (position! + (width * 2)) > 1 ? 1.0 : position! + (width * 2),
      1.0
    ];
    paint.blendMode = BlendMode.srcATop;
    paint.shader = LinearGradient(
      tileMode: TileMode.decal,
      begin: begin!,
      end: end!,
      colors: <Color>[
        Colors.transparent,
        baseColor!.withOpacity(0.03),
        highlightColor!.withOpacity(opacity),
        baseColor!.withOpacity(0.03),
        Colors.transparent
      ],
      stops: stops,
    ).createShader(Rect.fromLTRB(
        size.width * -0.5,
        (size.height > size.width) ? 0 : size.height * -0.5,
        size.width * 1.5,
        size.height * 1.5));

    final RRect borderRect = BorderRadius.circular(radius ?? 0.0)
        .toRRect(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    canvas.drawRRect(borderRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Shimmer extends StatelessWidget {
  const Shimmer({
    this.child,
    this.enabled = true,
    this.opacity = 0.3,
    this.highlightColor = Colors.white,
    this.radius,
    required this.baseColor,
    this.duration = const Duration(seconds: 3),
    this.interval = const Duration(seconds: 0),
    this.direction = const ShimmerDirection.fromLTRB(),
  });

  final Widget? child;

  final bool enabled;

  final double opacity;

  final Color highlightColor;

  final Color baseColor;

  final Duration duration;

  final Duration interval;

  final ShimmerDirection direction;

  final double? radius;

  @override
  Widget build(BuildContext context) {
    if (enabled)
      return ShimmerAnimator(
        child: child,
        highlightColor: highlightColor,
        baseColor: baseColor,
        duration: duration,
        interval: interval,
        direction: direction,
        radius: radius,
        opacity: opacity,
      );
    else
      return child!;
  }
}

/// A direction along which the shimmer animation will travel
///
///
/// Shimmer animation can travel in 6 possible directions:
///
/// Diagonal Directions:
/// - [ShimmerDirection.fromLTRB] : animation starts from Left Top and moves towards the Right Bottom. This is also the default behaviour if no direction is specified.
/// - [ShimmerDirection.fromRTLB] : animation starts from Right Top and moves towards the Left Bottom
/// - [ShimmerDirection.fromLBRT] : animation starts from Left Bottom and moves towards the Right Top
/// - [ShimmerDirection.fromRBLT] : animation starts from Right Bottom and moves towards the Left Top
///
/// Directions along the axes:
/// - [ShimmerDirection.fromLeftToRight] : animation starts from Left Center and moves towards the Right Center
/// - [ShimmerDirection.fromRightToLeft] : animation starts from Right Center and moves towards the Left Center
class ShimmerDirection {
  factory ShimmerDirection() => const ShimmerDirection._fromLTRB();

  const ShimmerDirection._fromLTRB({
    this.begin = Alignment.topLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRTLB({
    this.begin = Alignment.centerRight,
    this.end = Alignment.topLeft,
  });

  const ShimmerDirection._fromLBRT({
    this.begin = Alignment.bottomLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRBLT({
    this.begin = Alignment.topRight,
    this.end = Alignment.centerLeft,
  });

  const ShimmerDirection._fromLeftToRight({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRightToLeft({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  /// Animation starts from Left Top and moves towards the Right Bottom
  const factory ShimmerDirection.fromLTRB() = ShimmerDirection._fromLTRB;

  /// Animation starts from Right Top and moves towards the Left Bottom
  const factory ShimmerDirection.fromRTLB() = ShimmerDirection._fromRTLB;

  /// Animation starts from Left Bottom and moves towards the Right Top
  const factory ShimmerDirection.fromLBRT() = ShimmerDirection._fromLBRT;

  /// Animation starts from Right Bottom and moves towards the Left Top
  const factory ShimmerDirection.fromRBLT() = ShimmerDirection._fromRBLT;

  /// Animation starts from Left Center and moves towards the Right Center
  const factory ShimmerDirection.fromLeftToRight() =
      ShimmerDirection._fromLeftToRight;

  /// Animation starts from Right Center and moves towards the Left Center
  const factory ShimmerDirection.fromRightToLeft() =
      ShimmerDirection._fromRightToLeft;

  final Alignment begin, end;
}
