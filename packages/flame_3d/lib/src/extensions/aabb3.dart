import 'package:flame_3d/game.dart';
import 'package:vector_math/vector_math.dart' show Frustum;

/// Result of a frustum-AABB intersection test.
enum CullResult {
  /// The AABB is fully outside the frustum cull the entire subtree.
  outside,

  /// The AABB is fully inside the frustum, skip per-child tests.
  inside,

  /// The AABB partially overlaps the frustum, test children individually.
  intersecting,
}

extension Aabb3Extension on Aabb3 {
  /// Set the min and max from the [other].
  void setFrom(Aabb3 other) {
    min.setFrom(other.min);
    max.setFrom(other.max);
  }

  /// Set the min and max to zero.
  void setZero() {
    min.setZero();
    max.setZero();
  }

  /// Test this AABB against a [frustum] and return a [CullResult].
  ///
  /// - [CullResult.outside]: the AABB is fully outside at least one plane.
  /// - [CullResult.inside]: the AABB is fully inside all planes.
  /// - [CullResult.intersecting]: the AABB straddles at least one plane.
  CullResult frustumCullTest(Frustum frustum) {
    var allInside = true;

    for (final plane in [
      frustum.plane0,
      frustum.plane1,
      frustum.plane2,
      frustum.plane3,
      frustum.plane4,
      frustum.plane5,
    ]) {
      final normal = plane.normal;
      final constant = plane.constant;

      // Positive vertex: the AABB corner farthest along the plane normal.
      final px = normal.x >= 0.0 ? max.x : min.x;
      final py = normal.y >= 0.0 ? max.y : min.y;
      final pz = normal.z >= 0.0 ? max.z : min.z;

      // Negative vertex: the AABB corner nearest along the plane normal.
      final nx = normal.x >= 0.0 ? min.x : max.x;
      final ny = normal.y >= 0.0 ? min.y : max.y;
      final nz = normal.z >= 0.0 ? min.z : max.z;

      final d1 = normal.x * px + normal.y * py + normal.z * pz + constant;
      final d2 = normal.x * nx + normal.y * ny + normal.z * nz + constant;

      // If positive vertex is outside, entire AABB is outside this plane.
      if (d1 < 0) {
        return CullResult.outside;
      }

      // If negative vertex is outside, AABB straddles this plane.
      if (d2 < 0) {
        allInside = false;
      }
    }

    return allInside ? CullResult.inside : CullResult.intersecting;
  }
}
