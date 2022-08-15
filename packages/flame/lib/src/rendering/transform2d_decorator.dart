
import 'dart:ui';

import 'package:flame/src/game/transform2d.dart';
import 'package:flame/src/rendering/decorator.dart';

class Transform2DDecorator extends Decorator {
  Transform2DDecorator([Transform2D? transform])
    : transform2d = transform ?? Transform2D();

  final Transform2D transform2d;

  @override
  void apply(void Function(Canvas) draw, Canvas canvas) {
    canvas.save();
    canvas.transform(transform2d.transformMatrix.storage);
    draw(canvas);
    canvas.restore();
  }
}
