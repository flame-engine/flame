import 'dart:ui' show Color;

import 'package:flame_3d/game.dart';

/// Represents an immutable [Vector3].
typedef ImmutableVector3 = ({double x, double y, double z});

extension Vector3Extension on Vector3 {
  /// Returns an immutable representation of the vector.
  ImmutableVector3 get immutable => (x: x, y: y, z: z);

  Color toColor() {
    return Color.fromARGB(
      255,
      (x * 255).toInt().clamp(0, 255),
      (y * 255).toInt().clamp(0, 255),
      (z * 255).toInt().clamp(0, 255),
    );
  }
}

extension Vector3Math on ImmutableVector3 {
  List<double> get storage => [x, y, z];

  ImmutableVector3 operator -(Object v) {
    if (v is ImmutableVector3) {
      return (x: x - v.x, y: y - v.y, z: z - v.z);
    } else if (v is Vector3) {
      return (x: x - v.x, y: y - v.y, z: z - v.z);
    }
    throw UnsupportedError('${v.runtimeType}');
  }

  Vector3 get mutable => Vector3(x, y, z);
}
