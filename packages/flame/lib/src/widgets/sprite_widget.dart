import 'package:flutter/widgets.dart';

import '../../assets.dart';
import '../../extensions.dart';
import '../anchor.dart';
import 'animation_widget.dart';
import 'base_future_builder.dart';
import 'sprite_painter.dart';

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

  final Future<Sprite> Function() _spriteFuture;

  SpriteWidget({
    required Sprite sprite,
    this.anchor = Anchor.topLeft,
    this.angle = 0,
    this.srcPosition,
    this.srcSize,
    this.errorBuilder,
    this.loadingBuilder,
    Key? key,
  })  : _spriteFuture = (() => Future.value(sprite)),
        super(key: key);

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
        return _SpriteWidget(
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
class _SpriteWidget extends StatelessWidget {
  /// The [Sprite] to be rendered
  final Sprite sprite;

  /// The positioning [Anchor] for the [sprite]
  final Anchor anchor;

  /// The angle to rotate this [sprite], in rad. (default = 0)
  final double angle;

  const _SpriteWidget({
    required this.sprite,
    this.anchor = Anchor.topLeft,
    this.angle = 0,
  });

  @override
  Widget build(_) {
    return Container(
      child: CustomPaint(painter: SpritePainter(sprite, anchor, angle: angle)),
    );
  }
}
