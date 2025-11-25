import 'dart:ui';

import 'package:flame/text.dart';

class RectElement extends TextElement {
  RectElement(double width, double height, this._paint)
    : _rect = Rect.fromLTWH(0, 0, width, height);

  Rect _rect;
  final Paint _paint;

  @override
  void translate(double dx, double dy) {
    _rect = _rect.translate(dx, dy);
  }

  @override
  void draw(Canvas canvas) {
    canvas.drawRect(_rect, _paint);
  }

  @override
  Rect get boundingBox => _rect;
}
