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
class SpriteWidget extends StatelessWidget {
  /// The positioning [Anchor]
  final Anchor anchor;

  /// The angle to rotate this [Sprite], in rad. (default = 0)
  final double angle;

  /// A builder function that is called if the loading fails
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way
  final WidgetBuilder? loadingBuilder;

  /// A custom [Paint] to be used when rendering the sprite
  /// When omitted the default paint from the [Sprite] class will be used.
  final Paint? paint;

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
    super.key,
  }) : _spriteFuture = Sprite.load(
          path,
          srcSize: srcSize,
          srcPosition: srcPosition,
          images: images,
        );

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<Sprite>(
      future: _spriteFuture,
      builder: (_, sprite) {
        return InternalSpriteWidget(
          sprite: sprite,
          anchor: anchor,
          angle: angle,
          paint: paint,
        );
      },
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
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
