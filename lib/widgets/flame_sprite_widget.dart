import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import '../sprite.dart';

import 'dart:math';

class FlameSpriteWidget extends StatelessWidget {
  final Sprite sprite;
  final bool center;

  FlameSpriteWidget({
    @required this.sprite,
    this.center = false,
  }) : assert(sprite.loaded(), 'Sprite must be loaded');

  @override
  Widget build(_) {
    return Container(
      child: CustomPaint(painter: _FlameSpritePainer(sprite, center)),
    );
  }
}

class _FlameSpritePainer extends CustomPainter {
  final Sprite _sprite;
  final bool _center;

  _FlameSpritePainer(this._sprite, this._center);

  @override
  bool shouldRepaint(_FlameSpritePainer old) => old._sprite != _sprite || old._center != _center;

  @override
  void paint(Canvas canvas, Size size) {
    final widthRate = size.width / _sprite.size.x;
    final heightRate = size.height / _sprite.size.y;

    final rate = min(widthRate, heightRate);

    final rect = Rect.fromLTWH(
      0,
      0,
      _sprite.size.x * rate,
      _sprite.size.y * rate,
    );

    if (_center) {
      canvas.translate(
        size.width / 2 - rect.width / 2,
        size.height / 2 - rect.height / 2,
      );
    }

    _sprite.renderRect(canvas, rect);
  }
}
