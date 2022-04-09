import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

abstract class GeometricPrimitive {
  bool get isClosed;

  bool get isConvex;

  double get perimeter;

  Vector2 get center;

  Aabb2 get aabb;

  bool containsPoint(Vector2 point, {double epsilon = 1e-5});

  Path asPath();

  GeometricPrimitive project(Matrix4 transformMatrix);

  // Intersection? intersection(GeometricPrimitive other);
}
