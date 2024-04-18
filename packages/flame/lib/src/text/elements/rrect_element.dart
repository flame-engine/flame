import 'dart:ui';

import 'package:flame/text.dart';

class RRectElement extends TextElement {
  RRectElement(
    double width,
    double height,
    double radius,
    this._paint,
  ) : _rrect = RRect.fromLTRBR(0, 0, width, height, Radius.circular(radius));

  RRect _rrect;
  final Paint _paint;

  @override
  void translate(double dx, double dy) {
    _rrect = _rrect.shift(Offset(dx, dy));
  }

  @override
  void draw(Canvas canvas) {
    canvas.drawRRect(_rrect, _paint);
  }

  @override
  Rect get boundingBox => _rrect.outerRect;
}
