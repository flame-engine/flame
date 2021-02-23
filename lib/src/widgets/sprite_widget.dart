import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../anchor.dart';
import '../extensions/size.dart';
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
    @required this.sprite,
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
    final widthRate = size.width / _sprite.srcSize.x;
    final heightRate = size.height / _sprite.srcSize.y;
    final rate = min(widthRate, heightRate);

    final paintSize = _sprite.srcSize * rate;
    final anchorPosition = _anchor.toVector2();
    final anchoredPosition = size.toVector2()..multiply(anchorPosition);
    final delta = (anchoredPosition - paintSize)..multiply(anchorPosition);

    canvas.translate(delta.x, delta.y);
    _sprite.render(canvas, size: paintSize);
  }
}
