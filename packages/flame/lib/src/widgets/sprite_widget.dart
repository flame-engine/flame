import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/src/widgets/animation_widget.dart';
import 'package:flame/src/widgets/base_future_builder.dart';
import 'package:flame/src/widgets/sprite_painter.dart';
import 'package:flutter/widgets.dart';

export '../sprite.dart';

/// A [StatelessWidget] which renders a Sprite
/// To render an animation, use [SpriteAnimationWidget].
class SpriteWidget extends StatefulWidget {
  /// The positioning [Anchor]
  final Anchor anchor;

  /// The angle to rotate this [Sprite], in rad. (default = 0)
  final double angle;

  /// A builder function that is called if the loading fails
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way
  final WidgetBuilder? loadingBuilder;

  /// A custom [Paint] to be used when rendering the sprite.
  /// When omitted the default paint from the [Sprite] class will be used.
  final Paint? paint;

  /// If the Sprite should be rasterized or not.
  final bool rasterize;

  final FutureOr<Sprite> _spriteFuture;

  /// renders the [sprite] as a Widget.
  ///
  /// To change the source size and position, see [Sprite.new]
  const SpriteWidget({
    required Sprite sprite,
    this.anchor = Anchor.topLeft,
    this.angle = 0,
    this.errorBuilder,
    this.loadingBuilder,
    this.paint,
    this.rasterize = false,
    super.key,
  }) : _spriteFuture = sprite;

  /// Load the image from the asset [path] and renders it as a widget.
  ///
  /// It will use the [loadingBuilder] while the image from [path] is loading.
  /// To render without loading, or when you want to have a gapless playback
  /// when the [path] value changes, consider loading the image beforehand
  /// and direct pass it to the default constructor.
  SpriteWidget.asset({
    required String path,
    Images? images,
    this.anchor = Anchor.topLeft,
    this.angle = 0,
    Vector2? srcPosition,
    Vector2? srcSize,
    this.errorBuilder,
    this.loadingBuilder,
    this.paint,
    this.rasterize = false,
    super.key,
  }) : _spriteFuture = Sprite.load(
         path,
         srcSize: srcSize,
         srcPosition: srcPosition,
         images: images,
       );

  @override
  State<SpriteWidget> createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> {
  late FutureOr<Sprite> _spriteFuture = _initializeFuture();

  FutureOr<Sprite> _initializeFuture() async {
    if (!widget.rasterize) {
      return widget._spriteFuture;
    }

    final sprite = await widget._spriteFuture;
    return sprite.rasterize();
  }

  @override
  void didUpdateWidget(covariant SpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateSprite(
      widget.rasterize || oldWidget.rasterize,
      oldWidget._spriteFuture,
      widget._spriteFuture,
    );
  }

  Future<void> _updateSprite(
    bool rasterize,
    FutureOr<Sprite> oldFutureValue,
    FutureOr<Sprite> newFutureValue,
  ) async {
    final oldValue = await oldFutureValue;
    final newValue = await newFutureValue;

    if (rasterize && oldValue.image != newValue.image) {
      oldValue.image.dispose();
    }

    if (mounted &&
        (oldValue.image != newValue.image || oldValue.src != newValue.src)) {
      setState(() {
        _spriteFuture = _initializeFuture();
      });
    }
  }

  Future<void> _disposeImage() async {
    final value = await _spriteFuture;
    value.image.dispose();
  }

  @override
  void dispose() {
    if (widget.rasterize) {
      _disposeImage();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<Sprite>(
      future: _spriteFuture,
      builder: (_, sprite) {
        return InternalSpriteWidget(
          sprite: sprite,
          anchor: widget.anchor,
          angle: widget.angle,
          paint: widget.paint,
        );
      },
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}

/// A [StatefulWidget] that renders a still [Sprite].
@visibleForTesting
class InternalSpriteWidget extends StatelessWidget {
  /// The [Sprite] to be rendered
  final Sprite sprite;

  /// The positioning [Anchor] for the [sprite]
  final Anchor anchor;

  /// The angle to rotate this [sprite], in rad. (default = 0)
  final double angle;

  final Paint? paint;

  const InternalSpriteWidget({
    required this.sprite,
    this.anchor = Anchor.topLeft,
    this.angle = 0,
    this.paint,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpritePainter(sprite, anchor, paint, angle: angle),
      size: sprite.srcSize.toSize(),
    );
  }
}
