import 'dart:math' as math;

import 'package:flame_3d/camera.dart' show Ray;
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template ray_hit_3d}
/// A world-space ray intersection against an [Object3D] and one of its
/// [Surface]s.
/// {@endtemplate}
class RayHit3D({
  required final Object3D object,
  required final Surface surface,
  required final double distance,
  required final Vector3 worldPoint,
  required final Vector3 worldNormal,
  required final Vector3 localPoint,
  required final Vector3 localNormal,
  required final int triangleIndex,
  final int surfaceIndex = 0,
}) {
  /// Intersects [worldRay] against [mesh] transformed by [modelMatrix],
  /// returning the closest [RayHit3D] on [owner] within [maxDistance], or
  /// `null` when missed.
  static RayHit3D? intersectMesh({
    required Object3D owner,
    required Mesh mesh,
    required Matrix4 modelMatrix,
    required Ray worldRay,
    double maxDistance = double.infinity,
    CullMode? cullMode,
  }) {
    RayHit3D? best;
    var limit = maxDistance;
    var i = 0;
    for (final surface in mesh.surfaces) {
      final hit = intersectSurface(
        owner: owner,
        surface: surface,
        surfaceIndex: i,
        modelMatrix: modelMatrix,
        worldRay: worldRay,
        maxDistance: limit,
        cullMode: cullMode ?? surface.material.renderState.cullMode,
      );
      if (hit != null && hit.distance < limit) {
        limit = hit.distance;
        best = hit;
      }
      i++;
    }
    return best;
  }

  /// Intersects [worldRay] against [surface] transformed by [modelMatrix].
  static RayHit3D? intersectSurface({
    required Object3D owner,
    required Surface surface,
    required Matrix4 modelMatrix,
    required Ray worldRay,
    int surfaceIndex = 0,
    double maxDistance = double.infinity,
    CullMode cullMode = CullMode.none,
  }) {
    if (surface.indexCount < 3 || !(maxDistance > 0)) {
      return null;
    }
    final inv = _inverse..setFrom(modelMatrix);
    final det = inv.invert();
    if (det.abs() < 1e-15) {
      return null;
    }

    final m = inv.storage;
    final ox = worldRay.origin.x;
    final oy = worldRay.origin.y;
    final oz = worldRay.origin.z;
    final dx = worldRay.direction.x;
    final dy = worldRay.direction.y;
    final dz = worldRay.direction.z;

    // Affine transform preserves the ray parameter `t`:
    // `p_local(t) = M^-1 * (o + t * d)`.
    _localRay.origin.setValues(
      m[0] * ox + m[4] * oy + m[8] * oz + m[12],
      m[1] * ox + m[5] * oy + m[9] * oz + m[13],
      m[2] * ox + m[6] * oy + m[10] * oz + m[14],
    );
    _localRay.direction.setValues(
      m[0] * dx + m[4] * dy + m[8] * dz,
      m[1] * dx + m[5] * dy + m[9] * dz,
      m[2] * dx + m[6] * dy + m[10] * dz,
    );

    // `RenderContext3D` flips the GPU winding order when `det < 0`, so outward
    // CCW faces in local space remain front faces in world space, and
    // `(M^-1)^T * localNormal` already preserves outward orientation.
    final localHit = surface.bvh.raycast(
      _localRay,
      maxDistance: maxDistance,
      cullMode: cullMode,
    );
    if (localHit == null) {
      return null;
    }

    final t = localHit.distance;
    final worldPoint = Vector3(ox + dx * t, oy + dy * t, oz + dz * t);

    final lnx = localHit.normal.x;
    final lny = localHit.normal.y;
    final lnz = localHit.normal.z;
    var wnx = m[0] * lnx + m[1] * lny + m[2] * lnz;
    var wny = m[4] * lnx + m[5] * lny + m[6] * lnz;
    var wnz = m[8] * lnx + m[9] * lny + m[10] * lnz;
    final nLen = math.sqrt(wnx * wnx + wny * wny + wnz * wnz);
    if (nLen > 1e-12) {
      wnx /= nLen;
      wny /= nLen;
      wnz /= nLen;
    }

    return RayHit3D(
      object: owner,
      surface: surface,
      surfaceIndex: surfaceIndex,
      distance: t,
      worldPoint: worldPoint,
      worldNormal: Vector3(wnx, wny, wnz),
      localPoint: localHit.point,
      localNormal: localHit.normal,
      triangleIndex: localHit.triangleIndex,
    );
  }

  static final Matrix4 _inverse = Matrix4.identity();
  static final Ray _localRay = Ray();
}
