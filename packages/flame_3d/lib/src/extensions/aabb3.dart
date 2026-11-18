import 'package:flame_3d/game.dart';
import 'package:vector_math/vector_math.dart' show Frustum, Plane;

/// Result of a frustum-AABB intersection test.
enum CullResult() {
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
    // Unrolled over the six planes so the test allocates nothing.
    final r0 = _cullPlane(frustum.plane0);
    if (r0 == CullResult.outside) {
      return CullResult.outside;
    }
    final r1 = _cullPlane(frustum.plane1);
    if (r1 == CullResult.outside) {
      return CullResult.outside;
    }
    final r2 = _cullPlane(frustum.plane2);
    if (r2 == CullResult.outside) {
      return CullResult.outside;
    }
    final r3 = _cullPlane(frustum.plane3);
    if (r3 == CullResult.outside) {
      return CullResult.outside;
    }
    final r4 = _cullPlane(frustum.plane4);
    if (r4 == CullResult.outside) {
      return CullResult.outside;
    }
    final r5 = _cullPlane(frustum.plane5);
    if (r5 == CullResult.outside) {
      return CullResult.outside;
    }

    final allInside =
        r0 == CullResult.inside &&
        r1 == CullResult.inside &&
        r2 == CullResult.inside &&
        r3 == CullResult.inside &&
        r4 == CullResult.inside &&
        r5 == CullResult.inside;
    return allInside ? CullResult.inside : CullResult.intersecting;
  }

  CullResult _cullPlane(Plane plane) {
    final normal = plane.normal;
    final constant = plane.constant;
    final nx = normal.x;
    final ny = normal.y;
    final nz = normal.z;

    // Positive vertex: the AABB corner farthest along the plane normal.
    final d1 =
        nx * (nx >= 0.0 ? max.x : min.x) +
        ny * (ny >= 0.0 ? max.y : min.y) +
        nz * (nz >= 0.0 ? max.z : min.z) +
        constant;
    // If positive vertex is outside, entire AABB is outside this plane.
    if (d1 < 0) {
      return CullResult.outside;
    }

    // Negative vertex: the AABB corner nearest along the plane normal.
    final d2 =
        nx * (nx >= 0.0 ? min.x : max.x) +
        ny * (ny >= 0.0 ? min.y : max.y) +
        nz * (nz >= 0.0 ? min.z : max.z) +
        constant;
    // If negative vertex is outside, AABB straddles this plane.
    return d2 < 0 ? CullResult.intersecting : CullResult.inside;
  }
}
