import 'package:flame_3d/game.dart';

/// Represents an immutable [Vector3].
typedef ImmutableVector3 = ({double x, double y, double z});

extension Vector3Extension on Vector3 {
  /// Returns an immutable representation of the vector.
  ImmutableVector3 get immutable => (x: x, y: y, z: z);

  Vector3 lerp(Vector3 other, double t) {
    return Vector3Utils.lerp(this, other, t);
  }
}

extension Vector3Utils on Vector3 {
  static Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return a + (b - a).scaled(t);
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
