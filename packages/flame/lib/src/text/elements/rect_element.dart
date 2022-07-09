import 'dart:ui';

import 'package:flame/src/text/elements/block_element.dart';

class RectElement extends BlockElement {
  RectElement(super.width, super.height, this._paint)
      : _rect = Rect.fromLTWH(0, 0, width, height);

  Rect _rect;
  final Paint _paint;

  @override
  void translate(double dx, double dy) => _rect = _rect.translate(dx, dy);

  @override
  void render(Canvas canvas) => canvas.drawRect(_rect, _paint);
}
