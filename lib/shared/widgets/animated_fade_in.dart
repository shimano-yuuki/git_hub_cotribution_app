import 'package:flutter/material.dart';

/// フェードインアニメーション付きウィジェット
class AnimatedFadeIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double delay;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Interval(
        delay / (delay + duration.inMilliseconds),
        1.0,
        curve: curve,
      ),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

/// スライドインアニメーション付きウィジェット
class AnimatedSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;
  final double delay;

  const AnimatedSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0.0, 0.1),
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: beginOffset, end: Offset.zero),
      duration: duration,
      curve: Interval(
        delay / (delay + duration.inMilliseconds),
        1.0,
        curve: curve,
      ),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * MediaQuery.of(context).size.width,
            value.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// フェードイン + スライドインアニメーション付きウィジェット
class AnimatedFadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;
  final double delay;

  const AnimatedFadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0.0, 0.1),
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Interval(
        delay / (delay + duration.inMilliseconds),
        1.0,
        curve: curve,
      ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              beginOffset.dx * (1 - value) * MediaQuery.of(context).size.width,
              beginOffset.dy * (1 - value) * MediaQuery.of(context).size.height,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
