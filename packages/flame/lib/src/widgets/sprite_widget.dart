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

  /// Holds the position of the sprite on the image
  final Vector2? srcPosition;

  /// Holds the size of the sprite on the image
  final Vector2? srcSize;

  /// A builder function that is called if the loading fails
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way
  final WidgetBuilder? loadingBuilder;

  final FutureOr<Sprite> Function() _spriteFuture;

  SpriteWidget({
    required Sprite sprite,
    this.anchor = Anchor.topLeft,
    this.angle = 0,
    this.srcPosition,
    this.srcSize,
    Key? key,
  })  : _spriteFuture = (() => sprite),
        errorBuilder = null,
        loadingBuilder = null,
        super(key: key);

  /// loads image from asset [path] and renders it as Widget.
  /// it has [loadingBuilder] while the image from [path] loads image
  /// To render without loading or gapless playback when the [path] change,
  /// consider load an image from somewhere and directly pass it to
  /// default constructor
  SpriteWidget.asset({
    required String path,
    Images? images,
    this.anchor = Anchor.topLeft,
    this.angle = 0,
    this.srcPosition,
    this.srcSize,
    this.errorBuilder,
    this.loadingBuilder,
    Key? key,
  })  : _spriteFuture = (() => Sprite.load(
              path,
              srcSize: srcSize,
              srcPosition: srcPosition,
              images: images,
            )),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<Sprite>(
      futureBuilder: _spriteFuture,
      builder: (_, sprite) {
        return InternalSpriteWidget(
          sprite: sprite,
          anchor: anchor,
          angle: angle,
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

  const InternalSpriteWidget({
    required this.sprite,
    this.anchor = Anchor.topLeft,
    this.angle = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(_) {
    return Container(
      child: CustomPaint(painter: SpritePainter(sprite, anchor, angle: angle)),
    );
  }
}
