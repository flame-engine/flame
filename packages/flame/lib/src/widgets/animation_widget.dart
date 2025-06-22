import 'dart:async';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/cache/images.dart';
import 'package:flame/src/sprite_animation.dart';
import 'package:flame/src/sprite_animation_ticker.dart';
import 'package:flame/src/widgets/base_future_builder.dart';
import 'package:flame/src/widgets/sprite_painter.dart';
import 'package:flutter/material.dart' hide Animation;

export '../sprite_animation.dart';

/// A [StatelessWidget] that renders a [SpriteAnimation]
class SpriteAnimationWidget extends StatefulWidget {
  /// The positioning [Anchor].
  final Anchor anchor;

  /// Whether the animation should be playing or not.
  final bool playing;

  final FutureOr<SpriteAnimation> _animationFuture;
  final SpriteAnimationTicker? _animationTicker;

  /// A builder function that is called if the loading fails.
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way.
  final WidgetBuilder? loadingBuilder;

  /// A callback that is called when the animation completes.
  final VoidCallback? onComplete;

  /// A custom [Paint] to be used when rendering the sprite.
  /// When omitted the default paint from the [Sprite] class will be used.
  final Paint? paint;

  const SpriteAnimationWidget({
    required SpriteAnimation animation,
    required SpriteAnimationTicker animationTicker,
    this.playing = true,
    this.anchor = Anchor.topLeft,
    this.errorBuilder,
    this.loadingBuilder,
    this.onComplete,
    this.paint,
    super.key,
  })  : _animationFuture = animation,
        _animationTicker = animationTicker;

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
    this.onComplete,
    this.paint,
    super.key,
  })  : _animationFuture = SpriteAnimation.load(path, data, images: images),
        _animationTicker = null;

  @override
  State<SpriteAnimationWidget> createState() => _SpriteAnimationWidgetState();
}

class _SpriteAnimationWidgetState extends State<SpriteAnimationWidget> {
  late FutureOr<SpriteAnimation> _animationFuture = widget._animationFuture;
  late SpriteAnimationTicker? _animationTicker = widget._animationTicker;

  @override
  void didUpdateWidget(covariant SpriteAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateAnimation(
      oldWidget._animationFuture,
      widget._animationFuture,
      oldWidget._animationTicker,
      widget._animationTicker,
    );
  }

  Future<void> _updateAnimation(
    FutureOr<SpriteAnimation> oldFutureValue,
    FutureOr<SpriteAnimation> newFutureValue,
    SpriteAnimationTicker? oldTicker,
    SpriteAnimationTicker? newTicker,
  ) async {
    final oldValue = await oldFutureValue;
    final newValue = await newFutureValue;

    final areFramesDifferent = oldValue != newValue ||
        oldValue.frames.length != newValue.frames.length ||
        oldValue.frames.fold(
          true,
          (previous, frame) {
            final newFrame = newValue.frames[oldValue.frames.indexOf(frame)];

            return previous &&
                (frame.sprite.image == newFrame.sprite.image ||
                    frame.sprite.src == newFrame.sprite.src);
          },
        );

    if (mounted && (areFramesDifferent || oldTicker != newTicker)) {
      setState(() {
        _animationFuture = newFutureValue;
        _animationTicker = newTicker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<SpriteAnimation>(
      future: _animationFuture,
      builder: (_, spriteAnimation) {
        final ticker = _animationTicker ?? spriteAnimation.createTicker();
        ticker.completed.then((_) => widget.onComplete?.call());

        return InternalSpriteAnimationWidget(
          animation: spriteAnimation,
          animationTicker: ticker,
          anchor: widget.anchor,
          playing: widget.playing,
          paint: widget.paint,
        );
      },
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}

/// A [StatefulWidget] that render a [SpriteAnimation].
@visibleForTesting
class InternalSpriteAnimationWidget extends StatefulWidget {
  /// The [SpriteAnimation] to be rendered
  final SpriteAnimation animation;

  /// The [SpriteAnimationTicker] use for updating the [animation].
  final SpriteAnimationTicker animationTicker;

  /// The positioning [Anchor]
  final Anchor anchor;

  /// Should the [animation] be playing or not
  final bool playing;

  final Paint? paint;

  const InternalSpriteAnimationWidget({
    required this.animation,
    required this.animationTicker,
    this.playing = true,
    this.anchor = Anchor.topLeft,
    this.paint,
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
    _setupController();
    if (widget.playing) {
      _initAnimation();
    }
  }

  @override
  void didUpdateWidget(InternalSpriteAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animation != widget.animation) {
      oldWidget.animationTicker.onComplete = null;
      _setupController();
      if (widget.playing) {
        _initAnimation();
      }
    }

    if (widget.playing != oldWidget.playing) {
      if (widget.playing) {
        _initAnimation();
      } else {
        _pauseAnimation();
      }
    }
  }

  void _initAnimation() {
    widget.animationTicker.reset();
    _lastUpdated = DateTime.now().microsecondsSinceEpoch.toDouble();
    _controller?.repeat(
      // Approximately 60 fps
      period: const Duration(milliseconds: 16),
    );
  }

  void _setupController() {
    widget.animationTicker.onComplete = _pauseAnimation;
    _controller ??= AnimationController(vsync: this)
      ..addListener(_onAnimationValueChanged);
  }

  void _onAnimationValueChanged() {
    const microSecond = 1 / 1000000;

    final now = DateTime.now().microsecondsSinceEpoch.toDouble();
    final lastUpdated = _lastUpdated ??= now;
    final dt = (now - lastUpdated) * microSecond;

    final frameIndexBeforeTick = widget.animationTicker.currentIndex;
    widget.animationTicker.update(dt);
    final frameIndexAfterTick = widget.animationTicker.currentIndex;

    if (mounted && frameIndexBeforeTick != frameIndexAfterTick) {
      setState(() {});
    }
    _lastUpdated = now;
  }

  void _pauseAnimation() {
    _controller?.stop();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return CustomPaint(
      painter: SpritePainter(
        widget.animationTicker.getSprite(),
        widget.anchor,
        widget.paint,
      ),
    );
  }
}
