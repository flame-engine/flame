import 'package:vector_math/vector_math.dart' show Plane, Ray;

extension RayExtension on Ray {
  /// Returns the distance along this ray at which it crosses [plane] (the
  /// points `p` with `plane.normal.dot(p) + plane.constant == 0`), or null if
  /// the ray is parallel to the plane or crosses it behind its origin.
  ///
  /// The point itself is `at(t)`; the distance is in world units when the
  /// direction is unit length.
  double? intersectsWithPlane(Plane plane) {
    final normal = plane.normal;
    final denominator =
        normal.x * direction.x +
        normal.y * direction.y +
        normal.z * direction.z;
    if (denominator == 0) {
      return null;
    }
    final t =
        -(normal.x * origin.x +
            normal.y * origin.y +
            normal.z * origin.z +
            plane.constant) /
        denominator;
    return t >= 0 ? t : null;
  }
}
