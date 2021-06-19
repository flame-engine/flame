import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../assets.dart';
import '../../extensions.dart';
import '../anchor.dart';
import '../sprite.dart';
import 'animation_widget.dart';

export '../sprite.dart';

/// A [StatefulWidget] which loads a Sprite from metadata
/// and renders a [SpriteWidget]
class SpriteWidgetBuilder extends StatefulWidget {
  /// Image [path] used to build the sprite
  final String path;

  /// Images instance used to load the image, uses Flame.images when
  /// omitted
  final Images? images;

  /// The positioning [Anchor]
  final Anchor anchor;

  /// Holds the position of the sprite on the image
  final Vector2? srcPosition;

  /// Holds the size of the sprite on the image
  final Vector2? srcSize;

  const SpriteWidgetBuilder({
    required this.path,
    this.images,
    this.anchor = Anchor.topLeft,
    this.srcPosition,
    this.srcSize,
  });

  @override
  State createState() {
    return _SpriteWidgetBuilderState();
  }
}

class _SpriteWidgetBuilderState extends State<SpriteWidgetBuilder> {
  late Future<Sprite> _spriteFuture;

  @override
  void initState() {
    super.initState();

    _spriteFuture = Sprite.load(
      widget.path,
      srcSize: widget.srcSize,
      srcPosition: widget.srcPosition,
      images: widget.images,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Sprite>(
      future: _spriteFuture,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final sprite = snapshot.data;
          if (sprite != null) {
            return SpriteWidget(
              sprite: sprite,
              anchor: widget.anchor,
            );
          }
        }

        return Container();
      },
    );
  }
}

/// A [StatefulWidget] that renders a still [Sprite].
///
/// To render an animation, use [SpriteAnimationWidget].
class SpriteWidget extends StatelessWidget {
  /// The [Sprite] to be rendered
  final Sprite sprite;

  /// The positioning [Anchor] for the [sprite]
  final Anchor anchor;

  const SpriteWidget({
    required this.sprite,
    this.anchor = Anchor.topLeft,
  });

  @override
  Widget build(_) {
    return Container(
      child: CustomPaint(painter: _SpritePainter(sprite, anchor)),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final Sprite _sprite;
  final Anchor _anchor;

  _SpritePainter(this._sprite, this._anchor);

  @override
  bool shouldRepaint(_SpritePainter old) {
    return old._sprite != _sprite || old._anchor != _anchor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final boxSize = size.toVector2();
    final rate = boxSize.clone()..divide(_sprite.srcSize);
    final minRate = min(rate.x, rate.y);
    final paintSize = _sprite.srcSize * minRate;
    final anchorPosition = _anchor.toVector2();
    final boxAnchorPosition = boxSize..multiply(anchorPosition);
    final spriteAnchorPosition = anchorPosition..multiply(paintSize);

    canvas.translateVector(boxAnchorPosition..sub(spriteAnchorPosition));
    _sprite.render(canvas, size: paintSize);
  }
}
