import 'package:flame_3d/camera.dart' show Ray;
import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';

/// A single skeletal bone hitbox descriptor attached to a bone (by [boneName]
/// or [nodeIndex]) inside a [SkinnedHitboxRig3D].
class BoneHitbox3D {
  /// Creates a bone hitbox bound to either [boneName] or [nodeIndex].
  BoneHitbox3D({
    required this.shape,
    this.boneName,
    this.nodeIndex,
    String? name,
    Vector3? localOffset,
    Quaternion? localRotation,
    this.damageMultiplier = 1.0,
  }) : assert(
         boneName != null || nodeIndex != null,
         'Either boneName or nodeIndex must be provided',
       ),
       name = name ?? boneName ?? 'node_$nodeIndex',
       localOffset = localOffset?.clone() ?? Vector3.zero(),
       localRotation = localRotation?.clone() ?? Quaternion.identity();

  /// Creates a hitbox bound to the bone named [boneName].
  BoneHitbox3D.byName(
    String this.boneName, {
    required this.shape,
    String? name,
    Vector3? localOffset,
    Quaternion? localRotation,
    this.damageMultiplier = 1.0,
  }) : nodeIndex = null,
       name = name ?? boneName,
       localOffset = localOffset?.clone() ?? Vector3.zero(),
       localRotation = localRotation?.clone() ?? Quaternion.identity();

  /// Creates a hitbox bound to the bone at [nodeIndex].
  BoneHitbox3D.byIndex(
    int this.nodeIndex, {
    required this.shape,
    String? name,
    Vector3? localOffset,
    Quaternion? localRotation,
    this.damageMultiplier = 1.0,
  }) : boneName = null,
       name = name ?? 'node_$nodeIndex',
       localOffset = localOffset?.clone() ?? Vector3.zero(),
       localRotation = localRotation?.clone() ?? Quaternion.identity();

  /// Hitbox collision shape (e.g. [SphereShape3D], [CapsuleShape3D],
  /// [BoxShape3D]).
  final Shape3D shape;

  /// Optional target bone name in `Model.nodes`.
  final String? boneName;

  /// Optional target node index in `Model.nodes`.
  final int? nodeIndex;

  /// Logical hitbox label (e.g. `'head'`, `'spine'`, `'tail_tip'`).
  final String name;

  /// Local translation offset in bone space.
  final Vector3 localOffset;

  /// Local rotation offset in bone space.
  final Quaternion localRotation;

  /// Optional gameplay multiplier (e.g. headshot `2.0`).
  final double damageMultiplier;

  /// Cached world-space matrix (`model.worldTransformMatrix *
  /// node.combinedTransform * localTransform`) updated by [SkinnedHitboxRig3D].
  final Matrix4 worldMatrix = Matrix4.identity();

  /// Cached world-space AABB updated by [SkinnedHitboxRig3D].
  final Aabb3 worldAabb = Aabb3();

  int? _resolvedNodeIndex;
  String? _resolvedBoneName;
}

/// Accurate posed skeletal raycast hit returned by
/// [SkinnedHitboxRig3D.raycast].
class BoneRayHit3D({
  required final ModelComponent model,
  required final BoneHitbox3D hitbox,
  required final String boneName,
  required final int nodeIndex,
  required final Vector3 position,
  required final Vector3 normal,
  required final double distance,
});

/// Skeletal hitbox rig synchronizing [BoneHitbox3D] volumes to the live
/// animated pose of a [ModelComponent].
///
/// Unlike static `Surface.bvh` mesh raycasting (which tests rest/T-pose
/// geometry), [SkinnedHitboxRig3D.raycast] evaluates `model.evaluatePose()` and
/// tests posed bone transforms (`model.worldTransformMatrix *
/// node.combinedTransform`), enabling accurate hits on animated limbs, heads,
/// and multi-bone articulated creatures.
class SkinnedHitboxRig3D({
  List<BoneHitbox3D> hitboxes = const [],
  ModelComponent? model,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Component3D {
  /// Attached bone hitboxes.
  final List<BoneHitbox3D> hitboxes = List<BoneHitbox3D>.of(hitboxes);

  ModelComponent? _explicitModel = model;
  ModelComponent? _resolvedModel;

  final Aabb3 _unionAabb = Aabb3();
  bool _hasValidBounds = false;

  static final Vector3 _unitScale = Vector3.all(1.0);
  final Matrix4 _localOffsetMat = Matrix4.identity();
  final Ray _unitRay = Ray();

  /// Target [ModelComponent] driven by this rig.
  ModelComponent? get model => _explicitModel ?? _resolvedModel;
  set model(ModelComponent? value) {
    _explicitModel = value;
    _resolvedModel = value;
    for (final hb in hitboxes) {
      hb._resolvedNodeIndex = null;
      hb._resolvedBoneName = null;
    }
  }

  /// Adds a [BoneHitbox3D] to this rig.
  void addHitbox(BoneHitbox3D hitbox) {
    hitboxes.add(hitbox);
  }

  @override
  void onMount() {
    super.onMount();
    _resolveOwnerModel();
    syncTransforms();
  }

  @override
  void onRemove() {
    _resolvedModel = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    syncTransforms();
  }

  /// Evaluates the target [ModelComponent]'s current pose and updates every
  /// [BoneHitbox3D.worldMatrix] and [BoneHitbox3D.worldAabb] in place.
  void syncTransforms() {
    final owner = _explicitModel ?? _resolvedModel ?? _resolveOwnerModel();
    if (owner == null || hitboxes.isEmpty) {
      _hasValidBounds = false;
      return;
    }

    final workspace = owner.evaluatePose();
    final modelWorld = owner.worldTransformMatrix;
    var any = false;

    for (var i = 0; i < hitboxes.length; i++) {
      final hb = hitboxes[i];
      var idx = hb._resolvedNodeIndex;
      if (idx == null) {
        idx =
            hb.nodeIndex ??
            (hb.boneName == null
                ? null
                : owner.model.nodeIndexByName(hb.boneName!));
        if (idx == null) {
          continue;
        }
        hb._resolvedNodeIndex = idx;
        hb._resolvedBoneName =
            hb.boneName ?? owner.model.nodes[idx]?.name ?? 'node_$idx';
      }

      final processed = workspace.nodesByIndex[idx];
      if (processed == null) {
        continue;
      }

      _localOffsetMat.setFromTranslationRotationScale(
        hb.localOffset,
        hb.localRotation,
        _unitScale,
      );

      hb.worldMatrix
        ..setFrom(modelWorld)
        ..multiply(processed.combinedTransform)
        ..multiply(_localOffsetMat);

      hb.shape.computeWorldAabb(hb.worldMatrix, hb.worldAabb);
      if (!any) {
        _unionAabb
          ..min.setFrom(hb.worldAabb.min)
          ..max.setFrom(hb.worldAabb.max);
        any = true;
      } else {
        _unionAabb.hull(hb.worldAabb);
      }
    }
    _hasValidBounds = any;
  }

  /// Casts [worldRay] against all posed [hitboxes] within [maxDistance],
  /// returning the closest [BoneRayHit3D] or `null` when missed.
  BoneRayHit3D? raycast(
    Ray worldRay, {
    double maxDistance = double.infinity,
    bool syncPose = true,
  }) {
    if (!(maxDistance > 0.0)) {
      return null;
    }
    final dirLen = worldRay.direction.length;
    if (dirLen <= 1e-12) {
      return null;
    }
    if (syncPose) {
      syncTransforms();
    }
    final owner = _explicitModel ?? _resolvedModel;
    if (owner == null || !_hasValidBounds) {
      return null;
    }

    _unitRay.origin.setFrom(worldRay.origin);
    _unitRay.direction
      ..setFrom(worldRay.direction)
      ..scale(1.0 / dirLen);

    if (!_rayHitsAabb(_unitRay, _unionAabb, maxDistance)) {
      return null;
    }

    BoneRayHit3D? best;
    var limit = maxDistance;

    for (var i = 0; i < hitboxes.length; i++) {
      final hb = hitboxes[i];
      final idx = hb._resolvedNodeIndex;
      if (idx == null) {
        continue;
      }
      if (!_rayHitsAabb(_unitRay, hb.worldAabb, limit)) {
        continue;
      }
      final hit = hb.shape.raycast(
        _unitRay,
        hb.worldMatrix,
        maxDistance: limit,
      );
      if (hit != null && hit.$1 < limit) {
        limit = hit.$1;
        final t = hit.$1;
        best = BoneRayHit3D(
          model: owner,
          hitbox: hb,
          boneName: hb._resolvedBoneName ?? hb.name,
          nodeIndex: idx,
          position: Vector3(
            _unitRay.origin.x + _unitRay.direction.x * t,
            _unitRay.origin.y + _unitRay.direction.y * t,
            _unitRay.origin.z + _unitRay.direction.z * t,
          ),
          normal: hit.$2,
          distance: t,
        );
      }
    }
    return best;
  }

  /// Casts [worldRay] against all posed [hitboxes] within [maxDistance],
  /// returning every hit sorted from nearest to farthest.
  List<BoneRayHit3D> raycastAll(
    Ray worldRay, {
    double maxDistance = double.infinity,
    bool syncPose = true,
  }) {
    final hits = <BoneRayHit3D>[];
    if (!(maxDistance > 0.0)) {
      return hits;
    }
    final dirLen = worldRay.direction.length;
    if (dirLen <= 1e-12) {
      return hits;
    }
    if (syncPose) {
      syncTransforms();
    }
    final owner = _explicitModel ?? _resolvedModel;
    if (owner == null || !_hasValidBounds) {
      return hits;
    }

    _unitRay.origin.setFrom(worldRay.origin);
    _unitRay.direction
      ..setFrom(worldRay.direction)
      ..scale(1.0 / dirLen);

    if (!_rayHitsAabb(_unitRay, _unionAabb, maxDistance)) {
      return hits;
    }

    for (var i = 0; i < hitboxes.length; i++) {
      final hb = hitboxes[i];
      final idx = hb._resolvedNodeIndex;
      if (idx == null) {
        continue;
      }
      if (!_rayHitsAabb(_unitRay, hb.worldAabb, maxDistance)) {
        continue;
      }
      final hit = hb.shape.raycast(
        _unitRay,
        hb.worldMatrix,
        maxDistance: maxDistance,
      );
      if (hit != null) {
        final t = hit.$1;
        hits.add(
          BoneRayHit3D(
            model: owner,
            hitbox: hb,
            boneName: hb._resolvedBoneName ?? hb.name,
            nodeIndex: idx,
            position: Vector3(
              _unitRay.origin.x + _unitRay.direction.x * t,
              _unitRay.origin.y + _unitRay.direction.y * t,
              _unitRay.origin.z + _unitRay.direction.z * t,
            ),
            normal: hit.$2,
            distance: t,
          ),
        );
      }
    }
    hits.sort((a, b) => a.distance.compareTo(b.distance));
    return hits;
  }

  ModelComponent? _resolveOwnerModel() {
    if (_explicitModel != null) {
      return _resolvedModel = _explicitModel;
    }
    for (final ancestor in ancestors()) {
      if (ancestor is ModelComponent) {
        return _resolvedModel = ancestor;
      }
    }
    return null;
  }

  static bool _rayHitsAabb(Ray ray, Aabb3 box, double maxT) {
    var tMin = 0.0;
    var tMax = maxT;

    bool slab(double o, double d, double lo, double hi) {
      final minV = lo - 1e-5;
      final maxV = hi + 1e-5;
      if (d.abs() < 1e-12) {
        return o >= minV && o <= maxV;
      }
      final inv = 1.0 / d;
      var t1 = (minV - o) * inv;
      var t2 = (maxV - o) * inv;
      if (t1 > t2) {
        final s = t1;
        t1 = t2;
        t2 = s;
      }
      if (t1 > tMin) {
        tMin = t1;
      }
      if (t2 < tMax) {
        tMax = t2;
      }
      return tMin <= tMax;
    }

    return slab(ray.origin.x, ray.direction.x, box.min.x, box.max.x) &&
        slab(ray.origin.y, ray.direction.y, box.min.y, box.max.y) &&
        slab(ray.origin.z, ray.direction.z, box.min.z, box.max.z);
  }
}
