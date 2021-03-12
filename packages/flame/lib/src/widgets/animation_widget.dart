import 'dart:math';

import 'package:flutter/material.dart' hide Animation;

import '../anchor.dart';
import '../sprite_animation.dart';
import 'sprite_widget.dart';

export '../sprite_animation.dart';

/// A [StatefulWidget] that render a [SpriteAnimation].
class SpriteAnimationWidget extends StatefulWidget {
  /// The [SpriteAnimation] to be rendered
  final SpriteAnimation animation;

  /// The positioning [Anchor]
  final Anchor anchor;

  /// Should the [animation] be playing or not
  final bool playing;

  const SpriteAnimationWidget({
    required this.animation,
    this.playing = true,
    this.anchor = Anchor.topLeft,
  });

  @override
  State createState() => _AnimationWidget();
}

class _AnimationWidget extends State<SpriteAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double? _lastUpdated;

  @override
  void didUpdateWidget(SpriteAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing) {
      _initAnimation();
    } else {
      _pauseAnimation();
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this)
      ..addListener(() {
        final now = DateTime.now().millisecond.toDouble();

        final dt = max(0, (now - (_lastUpdated ?? 0)) / 1000).toDouble();
        widget.animation.update(dt);

        setState(() {
          _lastUpdated = now;
        });
      });

    widget.animation.onComplete = _pauseAnimation;

    if (widget.playing) {
      _initAnimation();
    }
  }

  void _initAnimation() {
    setState(() {
      widget.animation.reset();
      _lastUpdated = DateTime.now().millisecond.toDouble();
      _controller?.repeat(
        // Approximately 60 fps
        period: const Duration(milliseconds: 16),
      );
    });
  }

  void _pauseAnimation() {
    setState(() => _controller?.stop());
  }

  @override
  void dispose() {
    _controller?.dispose();
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
