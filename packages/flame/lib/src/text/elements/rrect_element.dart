import 'dart:ui';

import 'package:flame/src/text/elements/block_element.dart';

class RRectElement extends BlockElement {
  RRectElement(
    super.width,
    super.height,
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
  void render(Canvas canvas) {
    canvas.drawRRect(_rrect, _paint);
  }
}
