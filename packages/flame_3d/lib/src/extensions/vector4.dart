import 'dart:ui';

import 'package:flame_3d/game.dart';

/// Represents an immutable [Vector3].
typedef ImmutableVector4 = ({double x, double y, double z, double w});

extension Vector4Extension on Vector4 {
  /// Returns an immutable representation of the vector.
  ImmutableVector4 get immutable => (x: x, y: y, z: z, w: w);

  Vector4 lerp(Vector4 other, double t) {
    return Vector4Utils.lerp(this, other, t);
  }
}

class Vector4Utils {
  Vector4Utils._();

  static Vector4 lerp(Vector4 a, Vector4 b, double t) {
    return a + (b - a).scaled(t);
  }

  static Vector4 fromColor(Color color) {
    return Vector4(color.r, color.g, color.b, color.a);
  }
}

extension Vector4Math on ImmutableVector4 {
  List<double> get storage => [x, y, z, w];

  Vector4 get mutable => Vector4(x, y, z, w);
}
