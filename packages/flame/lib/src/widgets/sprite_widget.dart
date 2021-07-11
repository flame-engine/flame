import 'package:flutter/widgets.dart';

import '../../assets.dart';
import '../../extensions.dart';
import '../anchor.dart';
import '../sprite.dart';
import 'animation_widget.dart';
import 'base_future_builder.dart';
import 'sprite_painter.dart';

export '../sprite.dart';

/// A [StatelessWidget] which renders a Sprite
/// To render an animation, use [SpriteAnimationWidget].
class SpriteWidget extends StatelessWidget {
  /// The positioning [Anchor]
  final Anchor anchor;

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
    this.srcPosition,
    this.srcSize,
    this.errorBuilder,
    this.loadingBuilder,
  }) : _spriteFuture = (() => Future.value(sprite));

  SpriteWidget.asset({
    required String path,
    Images? images,
    this.anchor = Anchor.topLeft,
    this.srcPosition,
    this.srcSize,
    this.errorBuilder,
    this.loadingBuilder,
  }) : _spriteFuture = (() => Sprite.load(
              path,
              srcSize: srcSize,
              srcPosition: srcPosition,
              images: images,
            ));

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<Sprite>(
      futureBuilder: _spriteFuture,
      builder: (_, sprite) {
        return _SpriteWidget(
          sprite: sprite,
          anchor: anchor,
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

  const _SpriteWidget({
    required this.sprite,
    this.anchor = Anchor.topLeft,
  });

  @override
  Widget build(_) {
    return Container(
      child: CustomPaint(painter: SpritePainter(sprite, anchor)),
    );
  }
}
