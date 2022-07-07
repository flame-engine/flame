import 'dart:ui';

import 'package:flame/src/text/elements/element.dart';

class RRectBackgroundElement extends Element {
  RRectBackgroundElement(
    double width,
    double height,
    double radius,
    this._paints,
  ) : _rrect = RRect.fromLTRBR(0, 0, width, height, Radius.circular(radius));

  RRect _rrect;
  final List<Paint> _paints;

  @override
  void translate(double dx, double dy) {
    _rrect = _rrect.shift(Offset(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    for (final paint in _paints) {
      canvas.drawRRect(_rrect, paint);
    }
  }
}
