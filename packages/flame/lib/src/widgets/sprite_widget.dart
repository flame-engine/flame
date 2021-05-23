import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../extensions.dart';
import '../anchor.dart';
import '../sprite.dart';
import 'animation_widget.dart';

export '../sprite.dart';

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
