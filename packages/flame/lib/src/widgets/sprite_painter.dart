import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/src/sprite.dart';
import 'package:flutter/widgets.dart';

class SpritePainter extends CustomPainter {
  final Sprite _sprite;
  final Anchor _anchor;
  final double _angle;

  SpritePainter(this._sprite, this._anchor, {double angle = 0})
      : _angle = angle;

  @override
  bool shouldRepaint(SpritePainter old) {
    return old._sprite != _sprite ||
        old._anchor != _anchor ||
        old._angle != _angle;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final boxSize = size.toVector2();
    final rate = boxSize.clone()..divide(_sprite.srcSize);
    final minRate = min(rate.x, rate.y);
    final paintSize = _sprite.srcSize * minRate;
    final anchorPosition = _anchor.toVector2();
    final boxAnchorPosition = boxSize.clone()..multiply(anchorPosition);
    final spriteAnchorPosition = anchorPosition..multiply(paintSize);

    canvas.translateVector(boxAnchorPosition..sub(spriteAnchorPosition));

    if (_angle == 0) {
      _sprite.render(canvas, size: paintSize);
    } else {
      canvas.renderRotated(
        _angle,
        spriteAnchorPosition,
        (canvas) => _sprite.render(canvas, size: paintSize),
      );
    }
  }
}
