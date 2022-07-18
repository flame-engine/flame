import 'dart:math';
import 'dart:ui';

import 'package:flame/src/rendering/decorator.dart';
import 'package:vector_math/vector_math_64.dart';

/// [Rotate3DDecorator] treats the underlying component as if it was a flat
/// sheet of paper, and applies a 3D rotation to it.
///
/// The angles of rotation can be changed dynamically, allowing you to rotate
/// the content continuously at the desired angular speeds.
class Rotate3DDecorator extends Decorator {
  Rotate3DDecorator({
    Vector2? center,
    this.angleX = 0.0,
    this.angleY = 0.0,
    this.angleZ = 0.0,
    this.perspective = 0.001,
  }) : center = center ?? Vector2.zero();

  /// The center of rotation, in the **parent** coordinate space.
  Vector2 center;

  /// Angle of rotation around the X axis. This rotation is usually described as
  /// "vertical".
  double angleX;

  /// Angle of rotation around the Y axis. This rotation is typically described
  /// as "horizontal".
  double angleY;

  /// Angle of rotation around the Z axis. This is a regular "2D" rotation
  /// because it occurs entirely inside the plane in which the component is
  /// normally drawn.
  double angleZ;

  /// The strength of the perspective effect. In other words, how much the
  /// elements that are "behind" the canvas are shrunk, and those in front of
  /// it are expanded.
  double perspective;

  /// Returns `true` if the component is currently being rendered from its
  /// back side, and `false` if it shows the front side.
  ///
  /// The "front" side is the one displayed at `angleX = angleY = 0`, and the
  /// "back" side is shows if the component is rotated 180º degree around either
  /// the X or Y axis.
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
