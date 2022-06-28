import 'dart:async';
import 'dart:math';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/cache/images.dart';
import 'package:flame/src/sprite_animation.dart';
import 'package:flame/src/widgets/base_future_builder.dart';
import 'package:flame/src/widgets/sprite_painter.dart';
import 'package:flutter/material.dart' hide Animation;

export '../sprite_animation.dart';

/// A [StatelessWidget] that renders a [SpriteAnimation]
class SpriteAnimationWidget extends StatelessWidget {
  /// The positioning [Anchor]
  final Anchor anchor;

  /// Should the animation be playing or not
  final bool playing;

  final FutureOr<SpriteAnimation> _animationFuture;

  /// A builder function that is called if the loading fails
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way
  final WidgetBuilder? loadingBuilder;

  const SpriteAnimationWidget({
    required SpriteAnimation animation,
    this.playing = true,
    this.anchor = Anchor.topLeft,
    super.key,
  })  : _animationFuture = animation,
        errorBuilder = null,
        loadingBuilder = null;

  /// Loads image from the asset [path] and renders it as a widget.
  ///
  /// It will use the [loadingBuilder] while the image from [path] is loading.
  /// To render without loading, or when you want to have a gapless playback
  /// when the [path] value changes, consider loading the [SpriteAnimation]
  /// beforehand and direct pass it to the default constructor.
  SpriteAnimationWidget.asset({
    required String path,
    required SpriteAnimationData data,
    Images? images,
    this.playing = true,
    this.anchor = Anchor.topLeft,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  }) : _animationFuture = SpriteAnimation.load(
          path,
          data,
          images: images,
        );

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<SpriteAnimation>(
      future: _animationFuture,
      builder: (_, spriteAnimation) {
        return InternalSpriteAnimationWidget(
          animation: spriteAnimation,
          anchor: anchor,
          playing: playing,
        );
      },
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}

/// A [StatefulWidget] that render a [SpriteAnimation].
@visibleForTesting
class InternalSpriteAnimationWidget extends StatefulWidget {
  /// The [SpriteAnimation] to be rendered
  final SpriteAnimation animation;

  /// The positioning [Anchor]
  final Anchor anchor;

  /// Should the [animation] be playing or not
  final bool playing;

  const InternalSpriteAnimationWidget({
    required this.animation,
    this.playing = true,
    this.anchor = Anchor.topLeft,
    super.key,
  });

  @override
  State createState() => _InternalSpriteAnimationWidgetState();
}

class _InternalSpriteAnimationWidgetState
    extends State<InternalSpriteAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double? _lastUpdated;

  @override
  void initState() {
    super.initState();
    widget.animation.onComplete = _pauseAnimation;
    _setupController();
    if (widget.playing) {
      _initAnimation();
    }
  }

  @override
  void didUpdateWidget(InternalSpriteAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.onComplete = null;
      _setupController();
    }

    if (widget.playing) {
      _initAnimation();
    } else {
      _pauseAnimation();
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

  void _setupController() {
    _controller?.dispose();

    _controller = AnimationController(vsync: this)
      ..addListener(() {
        final now = DateTime.now().millisecond.toDouble();

        final dt = max(0, (now - (_lastUpdated ?? 0)) / 1000).toDouble();
        widget.animation.update(dt);

        setState(() => _lastUpdated = now);
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
    return Container(
      child: CustomPaint(
        painter: SpritePainter(
          widget.animation.getSprite(),
          widget.anchor,
        ),
      ),
    );
  }
}
