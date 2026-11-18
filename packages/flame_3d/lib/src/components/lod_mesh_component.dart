import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flame_3d/camera.dart' show Ray, RayHit3D;
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template mesh_lod_level}
/// One detail tier of a [LodMeshComponent], ordered from highest detail to
/// lowest detail.
///
/// A level matches when the object's camera distance is at most [maxDistance]
/// AND its projected clip-space height ratio (`projectedHeight / viewportHeight`)
/// is at least [minScreenHeightRatio]. The last level in the list acts as a
/// fallback when coarser thresholds are exceeded.
/// {@endtemplate}
class const MeshLodLevel({
  /// The mesh drawn at this detail tier.
  required final Mesh mesh,

  /// Maximum distance from the camera at which this tier is used.
  final double maxDistance = double.infinity,

  /// Minimum fraction of viewport height (`0..1+`) occupied by the component's
  /// bounding box for this tier to be selected (`0` disables screen-size
  /// gating).
  final double minScreenHeightRatio = 0.0,
});

/// {@template lod_mesh_component}
/// An [Object3D] that automatically selects one of its [levels] based on camera
/// distance and projected screen coverage, with an optional simplified
/// [shadowMesh] for directional shadow passes.
/// {@endtemplate}
class LodMeshComponent({
  required final List<MeshLodLevel> levels,
  var Mesh? shadowMesh,
  var bool lowestLodInShadowPass = false,
  var Color color = const Color(0xFFFFFFFF),
  Vector4? instanceData,
  super.position,
  super.scale,
  super.rotation,
  super.children,
  super.castsShadows,
}) extends Object3D {
  /// {@macro lod_mesh_component}
  this {
    if (levels.isEmpty) {
      throw ArgumentError.value(levels, 'levels', 'Must not be empty');
    }
  }

  /// Four floats of per-instance data forwarded to shaders.
  final Vector4 instanceData = instanceData?.clone() ?? Vector4.zero();

  int _lastSelectedLevel = 0;

  /// Index of the [levels] entry drawn in the most recent main pass.
  int get lastSelectedLevel => _lastSelectedLevel;

  @override
  Aabb3? computeLocalAabb() {
    final box = Aabb3.copy(levels.first.mesh.aabb);
    for (var i = 1; i < levels.length; i++) {
      box.hull(levels[i].mesh.aabb);
    }
    if (shadowMesh case final sm?) {
      box.hull(sm.aabb);
    }
    return box;
  }

  @override
  void draw(covariant RenderContext3D context) {
    if (context.isShadowPass) {
      final caster =
          shadowMesh ??
          (lowestLodInShadowPass
              ? levels.last.mesh
              : levels[_lastSelectedLevel].mesh);
      context.drawMesh(
        caster,
        transform: worldTransformMatrix,
        color: color,
        instanceData: instanceData,
      );
      return;
    }

    final index = _selectLevel(context);
    _lastSelectedLevel = index;
    context.drawMesh(
      levels[index].mesh,
      transform: worldTransformMatrix,
      color: color,
      instanceData: instanceData,
    );
  }

  @override
  RayHit3D? raycast(
    Ray worldRay, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
  }) {
    return RayHit3D.intersectMesh(
      owner: this,
      mesh: levels[_lastSelectedLevel].mesh,
      modelMatrix: worldTransformMatrix,
      worldRay: worldRay,
      maxDistance: maxDistance,
      cullMode: cullMode,
    );
  }

  int _selectLevel(RenderContext3D context) {
    if (levels.length == 1) {
      return 0;
    }
    final box = aabb;
    final cx = 0.5 * (box.min.x + box.max.x);
    final cy = 0.5 * (box.min.y + box.max.y);
    final cz = 0.5 * (box.min.z + box.max.z);
    final cam = context.cameraPosition;
    final dx = cx - cam.x;
    final dy = cy - cam.y;
    final dz = cz - cam.z;
    final dist = math.sqrt(dx * dx + dy * dy + dz * dz);

    final vp = context.viewProjection.storage;
    var minNdcY = double.infinity;
    var maxNdcY = double.negativeInfinity;
    for (var corner = 0; corner < 8; corner++) {
      final x = (corner & 1) == 0 ? box.min.x : box.max.x;
      final y = (corner & 2) == 0 ? box.min.y : box.max.y;
      final z = (corner & 4) == 0 ? box.min.z : box.max.z;
      final clipY = vp[1] * x + vp[5] * y + vp[9] * z + vp[13];
      final clipW = vp[3] * x + vp[7] * y + vp[11] * z + vp[15];
      final ndcY = clipW.abs() > 1e-6 ? clipY / clipW : clipY;
      minNdcY = math.min(minNdcY, ndcY);
      maxNdcY = math.max(maxNdcY, ndcY);
    }
    // Clip Y spans `[-1, 1]` (`2.0` full height).
    final screenRatio = 0.5 * math.max(0.0, maxNdcY - minNdcY);

    for (var i = 0; i < levels.length - 1; i++) {
      final level = levels[i];
      if (dist <= level.maxDistance &&
          screenRatio >= level.minScreenHeightRatio) {
        return i;
      }
    }
    return levels.length - 1;
  }
}
