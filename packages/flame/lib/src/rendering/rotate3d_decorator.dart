import 'dart:math';
import 'dart:ui';

import 'package:flame/src/rendering/decorator.dart';
import 'package:vector_math/vector_math_64.dart';

class Rotate3DDecorator extends Decorator {
  Rotate3DDecorator({
    Vector2? center,
    this.angleX = 0.0,
    this.angleY = 0.0,
    this.angleZ = 0.0,
    this.perspective = 0.001,
  }) : center = center ?? Vector2.zero();

  Vector2 center;
  double angleX;
  double angleY;
  double angleZ;
  double perspective;

  bool get isFlipped {
    const tau = 2 * pi;
    final phaseX = (angleX / tau - 0.25) % 1.0;
    final phaseY = (angleY / tau - 0.25) % 1.0;
    return (phaseX > 0.5) ^ (phaseY > 0.5);
  }

  @override
  void apply(void Function(Canvas) draw, Canvas canvas) {
    canvas.save();
    canvas.translate(center.x, center.y);
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, perspective)
      ..rotateX(angleX)
      ..rotateY(angleY)
      ..rotateZ(angleZ)
      ..translate(-center.x, -center.y);
    canvas.transform(matrix.storage);
    draw(canvas);
    canvas.restore();
  }
}
