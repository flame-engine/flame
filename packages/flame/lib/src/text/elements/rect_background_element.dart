
import 'dart:ui';

import 'package:flame/src/text/elements/element.dart';

class RectBackgroundElement extends Element {
  RectBackgroundElement(double width, double height, this._paints)
    : _rect = Rect.fromLTWH(0, 0, width, height);

  Rect _rect;
  final List<Paint> _paints;

  @override
  void translate(double dx, double dy) => _rect = _rect.translate(dx, dy);

  @override
  void render(Canvas canvas) {
    for (final paint in _paints) {
      canvas.drawRect(_rect, paint);
    }
  }
}
