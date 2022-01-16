import 'dart:math';

import 'package:flutter/material.dart' hide Animation;

import '../anchor.dart';
import '../assets/images.dart';
import '../sprite_animation.dart';
import 'base_future_builder.dart';
import 'sprite_painter.dart';

export '../sprite_animation.dart';

/// A [StatelessWidget] that renders a [SpriteAnimation]
class SpriteAnimationWidget extends StatelessWidget {
  /// The positioning [Anchor]
  final Anchor anchor;

  /// Should the animation be playing or not
  final bool playing;

  final Future<SpriteAnimation> Function() _animationFuture;

  /// A builder function that is called if the loading fails
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way
  final WidgetBuilder? loadingBuilder;

  SpriteAnimationWidget({
    required SpriteAnimation animation,
    this.playing = true,
    this.anchor = Anchor.topLeft,
    this.errorBuilder,
    this.loadingBuilder,
    Key? key,
  })  : _animationFuture = (() => Future.value(animation)),
        super(key: key);

  SpriteAnimationWidget.asset({
    required String path,
    required SpriteAnimationData data,
    Images? images,
    this.playing = true,
    this.anchor = Anchor.topLeft,
    this.errorBuilder,
    this.loadingBuilder,
    Key? key,
  })  : _animationFuture = (() => SpriteAnimation.load(
              path,
              data,
              images: images,
            )),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<SpriteAnimation>(
      futureBuilder: _animationFuture,
      builder: (_, spriteAnimation) {
        return _SpriteAnimationWidget(
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
class _SpriteAnimationWidget extends StatefulWidget {
  /// The [SpriteAnimation] to be rendered
  final SpriteAnimation animation;

  /// The positioning [Anchor]
  final Anchor anchor;

  /// Should the [animation] be playing or not
  final bool playing;

  const _SpriteAnimationWidget({
    required this.animation,
    this.playing = true,
    this.anchor = Anchor.topLeft,
  });

  @override
  State createState() => _SpriteAnimationWidgetState();
}

class _SpriteAnimationWidgetState extends State<_SpriteAnimationWidget>
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
  void didUpdateWidget(_SpriteAnimationWidget oldWidget) {
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
