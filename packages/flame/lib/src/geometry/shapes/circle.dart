import 'dart:ui';

import '../../extensions/vector2.dart';
import '../../game/transform2d.dart';
import 'shape.dart';

class Circle extends Shape {
  Circle(Vector2 center, this.radius)
    : _center = center.clone(),
      assert(radius > 0, 'Radius must be positive: $radius');

  final Vector2 _center;
  final double radius;
  static const tau = Transform2D.tau; // 2π

  @override
  bool get isClosed => true;

  @override
  bool get isConvex => true;

  @override
  Vector2 get center => _center;

  @override
  double get perimeter => radius * tau;

  @override
  Aabb2 get aabb => Aabb2.centerAndHalfExtents(_center, Vector2.all(radius));

  @override
  Path asPath() {
    final center = _center.toOffset();
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool containsPoint(Vector2 point, {double epsilon = 0.00001}) {
    return (point - _center).length2 <= radius * radius + epsilon;
  }

  @override
  Shape project(Transform2D transform) {
    if (transform.isTranslation) {
      final newCenter = transform.localToGlobal(_center);
      return Circle(newCenter, radius);
    }
    throw UnimplementedError();
  }
}
