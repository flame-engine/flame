import 'dart:math' as math;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';

/// Base procedural bone modifier applied in model space after keyframe
/// evaluation and before skinning joint matrices are written.
abstract class BoneModifier3D() {
  /// Blend weight in `[0, 1]` (`0` disables the modifier).
  double weight = 1.0;

  /// Advances any stateful simulation (such as spring velocity) by [dt].
  void step(double dt) {}

  /// Modifies node transforms inside [workspace] given [model] and the owning
  /// component's [worldMatrix] (and its inverse [invWorldMatrix]).
  void apply(
    Model model,
    ModelPoseWorkspace workspace,
    Matrix4 worldMatrix,
    Matrix4 invWorldMatrix,
    double dt,
  );

  /// Applies model-space delta matrix `delta = nextCombined * inv(oldCombined)`
  /// to every descendant of [modifiedNodeIndex] in topological order.
  static void propagateDeltaToDescendants(
    Model model,
    ModelPoseWorkspace workspace,
    int modifiedNodeIndex,
    Matrix4 oldCombined,
    Matrix4 nextCombined,
  ) {
    _invOld.copyInverse(oldCombined);
    _delta
      ..setFrom(nextCombined)
      ..multiply(_invOld);

    final affected = <int>{modifiedNodeIndex};
    for (final processed in workspace.orderedNodes) {
      final pIdx = processed.node.parentNodeIndex;
      if (pIdx != null && affected.contains(pIdx)) {
        affected.add(processed.node.nodeIndex);
        _temp
          ..setFrom(_delta)
          ..multiply(processed.combinedTransform);
        processed.combinedTransform.setFrom(_temp);
      }
    }
  }

  /// Rotates [combined] around its translation pivot `(m[12], m[13], m[14])` by
  /// model-space quaternion [deltaRot].
  static void rotateCombinedAroundOrigin(
    Matrix4 combined,
    Quaternion deltaRot,
  ) {
    final m = combined.storage;
    final ox = m[12];
    final oy = m[13];
    final oz = m[14];
    m[12] = 0;
    m[13] = 0;
    m[14] = 0;
    _rotMat.setFromTranslationRotation(Vector3.zero(), deltaRot);
    _temp
      ..setFrom(_rotMat)
      ..multiply(combined);
    _temp.storage[12] = ox;
    _temp.storage[13] = oy;
    _temp.storage[14] = oz;
    combined.setFrom(_temp);
  }

  /// Computes shortest-arc rotation from unit vector [fromDir] to unit vector
  /// [toDir] into [out], optionally clamped to [maxAngle] radians and scaled by
  /// [blendWeight].
  static void swingRotationInto(
    Vector3 fromDir,
    Vector3 toDir,
    Quaternion out, {
    double maxAngle = math.pi,
    double blendWeight = 1.0,
  }) {
    final dot = fromDir.dot(toDir).clamp(-1.0, 1.0);
    var angle = math.acos(dot);
    if (angle < 1e-6 || blendWeight <= 0.0) {
      out.setValues(0, 0, 0, 1);
      return;
    }
    if (angle > maxAngle) {
      angle = maxAngle;
    }
    angle *= blendWeight.clamp(0.0, 1.0);

    _axis.setFrom(fromDir.cross(toDir));
    if (_axis.length2 < 1e-10) {
      // Anti-parallel fallback axis.
      if (fromDir.x.abs() < 0.9) {
        _axis.setFrom(fromDir.cross(Vector3(1, 0, 0)));
      } else {
        _axis.setFrom(fromDir.cross(Vector3(0, 1, 0)));
      }
    }
    _axis.normalize();
    out.setAxisAngle(_axis, angle);
  }

  static final Matrix4 _invOld = Matrix4.identity();
  static final Matrix4 _delta = Matrix4.identity();
  static final Matrix4 _rotMat = Matrix4.identity();
  static final Matrix4 _temp = Matrix4.identity();
  static final Vector3 _axis = Vector3.zero();
}

/// Smoothly rotates a bone (such as a head, turret, or eye) so its local
/// [forwardAxis] aims toward [targetWorld], clamped to [maxAngle] radians.
class LookAtConstraint3D({
  required final String nodeName,
  Vector3? targetWorld,
  Vector3? forwardAxis,
  var double maxAngle = 1.25,
  double weight = 1.0,
}) extends BoneModifier3D {
  this {
    this.weight = weight;
  }

  /// World-space point to aim at.
  final Vector3 targetWorld = targetWorld?.clone() ?? Vector3.zero();

  /// Bone-local axis pointing forward (`(0, 0, 1)` by default).
  final Vector3 forwardAxis = (forwardAxis?.clone() ?? Vector3(0, 0, 1))
    ..normalize();

  int? _cachedIndex;
  final Vector3 _targetModel = Vector3.zero();
  final Vector3 _origin = Vector3.zero();
  final Vector3 _curForward = Vector3.zero();
  final Vector3 _desired = Vector3.zero();
  final Quaternion _deltaQ = Quaternion.identity();
  final Matrix4 _oldCombined = Matrix4.identity();

  @override
  void apply(
    Model model,
    ModelPoseWorkspace workspace,
    Matrix4 worldMatrix,
    Matrix4 invWorldMatrix,
    double dt,
  ) {
    if (weight <= 0.0) {
      return;
    }
    final idx = _cachedIndex ??= model.nodeIndexByName(nodeName);
    if (idx == null) {
      return;
    }
    final processed = workspace.nodesByIndex[idx];
    if (processed == null) {
      return;
    }

    final m = processed.combinedTransform;
    _oldCombined.setFrom(m);
    _origin.setValues(m.storage[12], m.storage[13], m.storage[14]);

    _targetModel.setFrom(targetWorld);
    invWorldMatrix.transform3(_targetModel);
    _desired
      ..setFrom(_targetModel)
      ..sub(_origin);
    final dist2 = _desired.length2;
    if (dist2 < 1e-10) {
      return;
    }
    _desired.scale(1.0 / math.sqrt(dist2));

    _curForward.setFrom(forwardAxis);
    m.rotate3(_curForward);
    final fLen2 = _curForward.length2;
    if (fLen2 < 1e-10) {
      return;
    }
    _curForward.scale(1.0 / math.sqrt(fLen2));

    BoneModifier3D.swingRotationInto(
      _curForward,
      _desired,
      _deltaQ,
      maxAngle: maxAngle,
      blendWeight: weight,
    );
    BoneModifier3D.rotateCombinedAroundOrigin(m, _deltaQ);
    BoneModifier3D.propagateDeltaToDescendants(
      model,
      workspace,
      idx,
      _oldCombined,
      m,
    );
  }
}

/// Damped Hooke-spring secondary-motion bone modifier for hair, capes, tails,
/// antennas, and foliage attachments.
class SpringBone3D({
  required final String nodeName,
  Vector3? localTipOffset,
  var double stiffness = 180.0,
  var double damping = 14.0,
  Vector3? gravity,
  var double maxAngle = 0.85,
  double weight = 1.0,
}) extends BoneModifier3D {
  this {
    this.weight = weight;
  }

  /// Bone-local vector from the bone pivot to its simulated tip.
  final Vector3 localTipOffset = localTipOffset?.clone() ?? Vector3(0, 0.5, 0);

  /// Constant world-space acceleration (such as gravity or wind) pulling the
  /// simulated tip.
  final Vector3 gravity = gravity?.clone() ?? Vector3.zero();

  int? _cachedIndex;
  bool _initialized = false;
  final Vector3 _simTipWorld = Vector3.zero();
  final Vector3 _velWorld = Vector3.zero();

  final Vector3 _pivotModel = Vector3.zero();
  final Vector3 _pivotWorld = Vector3.zero();
  final Vector3 _restTipModel = Vector3.zero();
  final Vector3 _restTipWorld = Vector3.zero();
  final Vector3 _simTipModel = Vector3.zero();
  final Vector3 _fromDir = Vector3.zero();
  final Vector3 _toDir = Vector3.zero();
  final Quaternion _deltaQ = Quaternion.identity();
  final Matrix4 _oldCombined = Matrix4.identity();

  /// Resets the spring tip to rest on the next evaluation.
  void reset() {
    _initialized = false;
    _velWorld.setZero();
  }

  /// Current world-space position of the simulated spring tip.
  Vector3 get currentTipWorld => _simTipWorld;

  @override
  void apply(
    Model model,
    ModelPoseWorkspace workspace,
    Matrix4 worldMatrix,
    Matrix4 invWorldMatrix,
    double dt,
  ) {
    if (weight <= 0.0) {
      return;
    }
    final idx = _cachedIndex ??= model.nodeIndexByName(nodeName);
    if (idx == null) {
      return;
    }
    final processed = workspace.nodesByIndex[idx];
    if (processed == null) {
      return;
    }

    final m = processed.combinedTransform;
    _oldCombined.setFrom(m);
    _pivotModel.setValues(m.storage[12], m.storage[13], m.storage[14]);
    _restTipModel.setFrom(localTipOffset);
    m.transform3(_restTipModel);

    _pivotWorld.setFrom(_pivotModel);
    worldMatrix.transform3(_pivotWorld);
    _restTipWorld.setFrom(_restTipModel);
    worldMatrix.transform3(_restTipWorld);

    final rodLen = (_restTipWorld - _pivotWorld).length;
    if (rodLen < 1e-6) {
      return;
    }

    if (!_initialized) {
      _simTipWorld.setFrom(_restTipWorld);
      _velWorld.setZero();
      _initialized = true;
      return;
    }

    final stepDt = dt.clamp(0.0, 0.05);
    if (stepDt > 0.0) {
      final ax =
          (_restTipWorld.x - _simTipWorld.x) * stiffness +
          gravity.x -
          _velWorld.x * damping;
      final ay =
          (_restTipWorld.y - _simTipWorld.y) * stiffness +
          gravity.y -
          _velWorld.y * damping;
      final az =
          (_restTipWorld.z - _simTipWorld.z) * stiffness +
          gravity.z -
          _velWorld.z * damping;

      _velWorld.setValues(
        _velWorld.x + ax * stepDt,
        _velWorld.y + ay * stepDt,
        _velWorld.z + az * stepDt,
      );
      _simTipWorld.setValues(
        _simTipWorld.x + _velWorld.x * stepDt,
        _simTipWorld.y + _velWorld.y * stepDt,
        _simTipWorld.z + _velWorld.z * stepDt,
      );

      // Distance constraint keeps the bone length invariant.
      final dx = _simTipWorld.x - _pivotWorld.x;
      final dy = _simTipWorld.y - _pivotWorld.y;
      final dz = _simTipWorld.z - _pivotWorld.z;
      final dLen = math.sqrt(dx * dx + dy * dy + dz * dz);
      if (dLen > 1e-6) {
        final s = rodLen / dLen;
        _simTipWorld.setValues(
          _pivotWorld.x + dx * s,
          _pivotWorld.y + dy * s,
          _pivotWorld.z + dz * s,
        );
      } else {
        _simTipWorld.setFrom(_restTipWorld);
      }
    }

    _simTipModel.setFrom(_simTipWorld);
    invWorldMatrix.transform3(_simTipModel);

    _fromDir
      ..setFrom(_restTipModel)
      ..sub(_pivotModel);
    _toDir
      ..setFrom(_simTipModel)
      ..sub(_pivotModel);
    if (_fromDir.length2 < 1e-10 || _toDir.length2 < 1e-10) {
      return;
    }
    _fromDir.normalize();
    _toDir.normalize();

    BoneModifier3D.swingRotationInto(
      _fromDir,
      _toDir,
      _deltaQ,
      maxAngle: maxAngle,
      blendWeight: weight,
    );
    BoneModifier3D.rotateCombinedAroundOrigin(m, _deltaQ);
    BoneModifier3D.propagateDeltaToDescendants(
      model,
      workspace,
      idx,
      _oldCombined,
      m,
    );
  }
}

/// Analytic Law-of-Cosines two-bone Inverse Kinematics solver for limbs
/// (`root` -> `mid` -> `tip`, such as shoulder-elbow-hand or hip-knee-foot)
/// with a world-space [poleWorld] bend-direction hint.
class TwoBoneIkConstraint3D({
  required final String rootNodeName,
  required final String midNodeName,
  required final String tipNodeName,
  Vector3? targetWorld,
  Vector3? poleWorld,
  double weight = 1.0,
}) extends BoneModifier3D {
  this {
    this.weight = weight;
  }

  /// Desired world-space position of the `tip` joint.
  final Vector3 targetWorld = targetWorld?.clone() ?? Vector3.zero();

  /// World-space pole target steering the knee/elbow bend plane.
  final Vector3 poleWorld = poleWorld?.clone() ?? Vector3(0, 0, 1);

  int? _rootIdx;
  int? _midIdx;
  int? _tipIdx;

  final Vector3 _pRoot = Vector3.zero();
  final Vector3 _pMid = Vector3.zero();
  final Vector3 _pTip = Vector3.zero();
  final Vector3 _targetM = Vector3.zero();
  final Vector3 _poleM = Vector3.zero();
  final Vector3 _dirTarget = Vector3.zero();
  final Vector3 _poleProj = Vector3.zero();
  final Vector3 _newMid = Vector3.zero();
  final Vector3 _oldUpper = Vector3.zero();
  final Vector3 _newUpper = Vector3.zero();
  final Vector3 _curLower = Vector3.zero();
  final Vector3 _newLower = Vector3.zero();
  final Vector3 _goalTip = Vector3.zero();
  final Quaternion _qRoot = Quaternion.identity();
  final Quaternion _qMid = Quaternion.identity();
  final Matrix4 _oldRootM = Matrix4.identity();
  final Matrix4 _oldMidM = Matrix4.identity();

  @override
  void apply(
    Model model,
    ModelPoseWorkspace workspace,
    Matrix4 worldMatrix,
    Matrix4 invWorldMatrix,
    double dt,
  ) {
    final w = weight.clamp(0.0, 1.0);
    if (w <= 0.0) {
      return;
    }
    final rIdx = _rootIdx ??= model.nodeIndexByName(rootNodeName);
    final mIdx = _midIdx ??= model.nodeIndexByName(midNodeName);
    final tIdx = _tipIdx ??= model.nodeIndexByName(tipNodeName);
    if (rIdx == null || mIdx == null || tIdx == null) {
      return;
    }

    final rootNode = workspace.nodesByIndex[rIdx];
    final midNode = workspace.nodesByIndex[mIdx];
    final tipNode = workspace.nodesByIndex[tIdx];
    if (rootNode == null || midNode == null || tipNode == null) {
      return;
    }

    final rm = rootNode.combinedTransform;
    final mm = midNode.combinedTransform;
    final tm = tipNode.combinedTransform;
    _pRoot.setValues(rm.storage[12], rm.storage[13], rm.storage[14]);
    _pMid.setValues(mm.storage[12], mm.storage[13], mm.storage[14]);
    _pTip.setValues(tm.storage[12], tm.storage[13], tm.storage[14]);

    final lenA = (_pMid - _pRoot).length;
    final lenB = (_pTip - _pMid).length;
    if (lenA < 1e-5 || lenB < 1e-5) {
      return;
    }

    _targetM.setFrom(targetWorld);
    invWorldMatrix.transform3(_targetM);
    _poleM.setFrom(poleWorld);
    invWorldMatrix.transform3(_poleM);

    _dirTarget
      ..setFrom(_targetM)
      ..sub(_pRoot);
    final rawDist = _dirTarget.length;
    if (rawDist < 1e-6) {
      return;
    }
    _dirTarget.scale(1.0 / rawDist);

    final minReach = (lenA - lenB).abs() + 1e-4;
    final maxReach = lenA + lenB - 1e-4;
    final clampedDist = rawDist.clamp(minReach, maxReach);

    // Law of cosines for angle at `root` between `dirTarget` and upper limb:
    final cosAlpha =
        ((lenA * lenA + clampedDist * clampedDist - lenB * lenB) /
                (2.0 * lenA * clampedDist))
            .clamp(-1.0, 1.0);
    final sinAlpha = math.sqrt(math.max(0.0, 1.0 - cosAlpha * cosAlpha));

    // Orthogonalize `pole - root` against `dirTarget` for bend direction.
    _poleProj
      ..setFrom(_poleM)
      ..sub(_pRoot);
    final proj = _poleProj.dot(_dirTarget);
    _poleProj.addScaled(_dirTarget, -proj);
    if (_poleProj.length2 < 1e-8) {
      // Fallback perpendicular to `dirTarget`.
      if (_dirTarget.x.abs() < 0.9) {
        _poleProj.setFrom(_dirTarget.cross(Vector3(1, 0, 0)));
      } else {
        _poleProj.setFrom(_dirTarget.cross(Vector3(0, 1, 0)));
      }
    }
    _poleProj.normalize();

    _newMid
      ..setFrom(_pRoot)
      ..addScaled(_dirTarget, lenA * cosAlpha)
      ..addScaled(_poleProj, lenA * sinAlpha);

    // 1. Rotate `root` so `(pMid - pRoot)` swings onto `(newMid - pRoot)`.
    _oldUpper
      ..setFrom(_pMid)
      ..sub(_pRoot)
      ..normalize();
    _newUpper
      ..setFrom(_newMid)
      ..sub(_pRoot)
      ..normalize();
    _oldRootM.setFrom(rm);
    BoneModifier3D.swingRotationInto(
      _oldUpper,
      _newUpper,
      _qRoot,
      blendWeight: w,
    );
    BoneModifier3D.rotateCombinedAroundOrigin(rm, _qRoot);
    BoneModifier3D.propagateDeltaToDescendants(
      model,
      workspace,
      rIdx,
      _oldRootM,
      rm,
    );

    // Re-read updated `mid` and `tip` positions after `root` rotation.
    _pMid.setValues(mm.storage[12], mm.storage[13], mm.storage[14]);
    _pTip.setValues(tm.storage[12], tm.storage[13], tm.storage[14]);
    _goalTip
      ..setFrom(_pRoot)
      ..addScaled(_dirTarget, clampedDist);

    // 2. Rotate `mid` so `(pTip - pMid)` swings onto `(goalTip - pMid)`.
    _curLower
      ..setFrom(_pTip)
      ..sub(_pMid);
    _newLower
      ..setFrom(_goalTip)
      ..sub(_pMid);
    if (_curLower.length2 < 1e-10 || _newLower.length2 < 1e-10) {
      return;
    }
    _curLower.normalize();
    _newLower.normalize();

    _oldMidM.setFrom(mm);
    BoneModifier3D.swingRotationInto(
      _curLower,
      _newLower,
      _qMid,
      blendWeight: w,
    );
    BoneModifier3D.rotateCombinedAroundOrigin(mm, _qMid);
    BoneModifier3D.propagateDeltaToDescendants(
      model,
      workspace,
      mIdx,
      _oldMidM,
      mm,
    );
  }
}
