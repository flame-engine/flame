import 'dart:ui';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'shape.dart';

// TODO: Split this up and move some down
/// The list of vertices used for collision detection and to define whether
/// a point is inside of the component or not, so that the tap detection etc
/// can be more accurately performed.
/// The hitbox is defined from the center of the component and with
/// percentages of the size of the component.
/// Example: [[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], [0.0, -1.0]]
/// This will form a rectangle with a 45 degree angle (pi/4 rad) within the
/// bounding size box.
/// NOTE: Always define your shape is a clockwise fashion
class Circle extends Shape {
  double definition;

  Circle({
    this.definition = 1.0,
    Vector2 position,
    Vector2 size,
    double angle,
  }) : super(position: position, size: size, angle: angle = 0);

  /// With this helper method you can create your [Circle] from a radius and
  /// a position. This helper will also calculate the bounding rectangle [size]
  /// for the [Circle].
  //TODO: Is "factory" really helping with anything here?
  factory Circle.fromRadius(
    double radius,
    Vector2 position, {
    double angle = 0,
  }) {
    return Circle(
      position: position,
      size: Vector2.all(radius * 2),
      angle: angle,
    );
  }

  double get radius {
    return (size.x / 2) * definition;
  }

  @override
  void render(Canvas canvas, Paint paint) {
    canvas.drawCircle(position.toOffset(), radius, paint);
  }

  /// Checks whether the represented circle contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return position.distanceToSquared(point) < radius * radius;
  }
}

class HitboxCircle extends Circle with HitboxShape {
  HitboxCircle() : super();
}
