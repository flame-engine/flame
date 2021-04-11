import 'dart:math';

import 'package:flutter/material.dart' hide Animation;

import '../anchor.dart';
import '../sprite_animation.dart';
import 'sprite_widget.dart';

export '../sprite_animation.dart';

/// A [StatefulWidget] that renders a [SpriteAnimation].
///
/// []
class SpriteAnimationWidget extends StatefulWidget {
  /// The [SpriteAnimation] to be rendered
  final SpriteAnimation animation;

  /// The positioning [Anchor] odf the animation. in relation to the current layout
  /// constraints.
  ///
  /// Defaults to [Anchor.topLeft].
  final Anchor anchor;

  /// Controls whether the animation is playing or not.
  ///
  /// Defaults to `true`
  final bool playing;

  const SpriteAnimationWidget({
    required this.animation,
    this.playing = true,
    this.anchor = Anchor.topLeft,
  });

  @override
  State createState() => SpriteAnimationWidgetState();
}

class SpriteAnimationWidgetState extends State<SpriteAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  double? lastUpdated;

  @override
  void didUpdateWidget(SpriteAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing) {
      initAnimation();
    } else {
      pauseAnimation();
    }
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this)
      ..addListener(() {
        final now = DateTime.now().millisecond.toDouble();

        final dt = max(0, (now - (lastUpdated ?? 0)) / 1000).toDouble();
        widget.animation.update(dt);

        setState(() {
          lastUpdated = now;
        });
      });

    widget.animation.onComplete = pauseAnimation;

    if (widget.playing) {
      initAnimation();
    }
  }

  void initAnimation() {
    setState(() {
      widget.animation.reset();
      lastUpdated = DateTime.now().millisecond.toDouble();
      controller?.repeat(
        // Approximately 60 fps
        period: const Duration(milliseconds: 16),
      );
    });
  }

  void pauseAnimation() {
    setState(() => controller?.stop());
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return SpriteWidget(
      sprite: widget.animation.getSprite(),
      anchor: widget.anchor,
    );
  }
}
