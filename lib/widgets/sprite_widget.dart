import 'package:flame/sprite_animation.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'dart:math';

import '../sprite.dart';
import '../anchor.dart';

/// A [StatefulWidget] that renders a still [Sprite].
///
/// To render an animation, use [SpriteAnimationWidget].
class SpriteWidget extends StatelessWidget {
  /// The [Sprite] to be rendered
  final Sprite sprite;

  /// The positioning [Anchor] for the [sprite]
  final Anchor anchor;

  SpriteWidget({
    @required this.sprite,
    this.anchor = Anchor.topLeft,
  }) : assert(sprite.loaded(), 'Sprite must be loaded');

  @override
  Widget build(_) {
    return Container(
      child: CustomPaint(painter: _SpritePainer(sprite, anchor)),
    );
  }
}

class _SpritePainer extends CustomPainter {
  final Sprite _sprite;
  final Anchor _anchor;

  _SpritePainer(this._sprite, this._anchor);

  @override
  bool shouldRepaint(_SpritePainer old) {
    return old._sprite != _sprite || old._anchor != _anchor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final widthRate = size.width / _sprite.size.x;
    final heightRate = size.height / _sprite.size.y;

    final rate = min(widthRate, heightRate);

    final w = _sprite.size.x * rate;
    final h = _sprite.size.y * rate;

    final double dx = _anchor.relativePosition.dx * size.width;
    final double dy = _anchor.relativePosition.dy * size.height;

    canvas.translate(
      dx - w * _anchor.relativePosition.dx,
      dy - h * _anchor.relativePosition.dy,
    );

    _sprite.render(canvas, width: w, height: h);
  }
}
