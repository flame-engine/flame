import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../../game/transform2d.dart';
import 'shape.dart';

class LineSegment extends Shape {
  LineSegment(this.from, this.to)
      : assert(from != to, 'Two distinct points required for a LineSegment');

  final Vector2 from;
  final Vector2 to;

  @override
  bool get isClosed => false;

  @override
  bool get isConvex => true;

  @override
  Vector2 get center => (from + to)..scale(0.5);

  @override
  double get perimeter => (to - from).length;

  @override
  Aabb2 get aabb {
    final minX = min(from.x, to.x);
    final maxX = max(from.x, to.x);
    final minY = min(from.y, to.y);
    final maxY = max(from.y, to.y);
    return Aabb2.minMax(Vector2(minX, minY), Vector2(maxX, maxY));
  }

  @override
  Path asPath() {
    return Path()
      ..moveTo(from.x, from.y)
      ..lineTo(to.x, to.y);
  }

  @override
  bool containsPoint(Vector2 point, {double epsilon = 0.00001}) {
    final crossProduct = (to.x - from.x) * (point.y - from.y) -
        (to.y - from.y) * (point.x - from.x);
    return (crossProduct.abs() <= epsilon) &&
        (to.x - point.x) * (point.x - from.x) >= 0 &&
        (to.y - point.y) * (point.y - from.y) >= 0;
  }

  @override
  Shape project(Transform2D transform) {
    final newFrom = transform.localToGlobal(from);
    final newTo = transform.localToGlobal(to);
    return LineSegment(newFrom, newTo);
  }
}
