import 'dart:ui' show Color;

import 'package:flame_3d/game.dart';

/// Represents an immutable [Vector3].
typedef ImmutableVector4 = ({double x, double y, double z, double w});

extension Vector4Extension on Vector4 {
  /// Returns an immutable representation of the vector.
  ImmutableVector4 get immutable => (x: x, y: y, z: z, w: w);

  Color toColor() {
    return Color.fromARGB(
      (w * 255).toInt(),
      (x * 255).toInt(),
      (y * 255).toInt(),
      (z * 255).toInt(),
    );
  }
}

extension Vector4Math on ImmutableVector4 {
  List<double> get storage => [x, y, z, w];

  Vector4 get mutable => Vector4(x, y, z, w);
}
