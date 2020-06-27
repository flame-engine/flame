import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'dart:math';

import '../sprite.dart';
import '../anchor.dart';

class SpriteWidget extends StatelessWidget {
  final Sprite sprite;
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

    final double dx = _anchor.x * size.width;
    final double dy = _anchor.y * size.height;

    canvas.translate(
      dx - w * _anchor.x,
      dy - h * _anchor.y,
    );

    _sprite.render(canvas, width: w, height: h);
  }
}
