import 'dart:ui';

import 'package:flame/text.dart';

class RectElement(double width, double height, final Paint _paint)
    extends TextElement {
  Rect _rect = Rect.fromLTWH(0, 0, width, height);
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
