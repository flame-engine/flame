import 'dart:math' as math;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/model/animation_state.dart';
import 'package:flame_3d/src/model/model.dart';

/// Ground plane along which [RootMotionExtractor3D] locks horizontal root
/// translation and measures yaw rotation.
enum RootMotionPlane3D() {
  /// Horizontal ground plane is `XZ` (`+Y` is up).
  xz,

  /// Horizontal ground plane is `XY` (`+Z` is up).
  xy,
}

/// Extracts per-tick root/hips translation (`deltaPositionLocal`,
/// `deltaPositionWorld`) and yaw (`deltaYawRad`) from an animated [Model]
/// without backwards spikes on loop wraps, and optionally locks root
/// translation in place on the visual skeleton.
class RootMotionExtractor3D({
  final String? rootNodeName,
  final int? rootNodeIndex,
  var bool lockHorizontalInPlace = true,
  var bool lockVerticalInPlace = false,
  var RootMotionPlane3D horizontalPlane = RootMotionPlane3D.xz,
  var bool applyToComponentTransform = false,
}) {
  final Vector3 _deltaLocal = Vector3.zero();
  final Vector3 _deltaWorld = Vector3.zero();
  double _deltaYawRad = 0.0;

  final Vector3 _prevPos = Vector3.zero();
  double _prevYaw = 0.0;
  bool _initialized = false;

  int? _resolvedIndex;
  Model? _boundModel;
  List<int>? _chainIndices;
  final Vector3 _anchorModelPos = Vector3.zero();

  final Vector3 _currPos = Vector3.zero();
  final Vector3 _startPos = Vector3.zero();
  final Vector3 _endPos = Vector3.zero();
  final Matrix4 _chainCombined = Matrix4.identity();
  final Matrix4 _chainScratch = Matrix4.identity();

  /// Model-space root bone displacement extracted during the most recent tick.
  Vector3 get deltaPositionLocal => _deltaLocal;

  /// World-space root bone displacement extracted during the most recent tick.
  Vector3 get deltaPositionWorld => _deltaWorld;

  /// Signed yaw rotation delta (in radians) around the vertical axis extracted
  /// during the most recent tick.
  double get deltaYawRad => _deltaYawRad;

  /// Resets previous-frame tracking and clears extracted deltas.
  void reset() {
    _initialized = false;
    _deltaLocal.setZero();
    _deltaWorld.setZero();
    _deltaYawRad = 0.0;
  }

  /// Clears per-tick deltas when an animation tick is paused or skipped.
  void clearStepDeltas() {
    _deltaLocal.setZero();
    _deltaWorld.setZero();
    _deltaYawRad = 0.0;
  }

  int? _resolveRootNode(Model model) {
    if (identical(model, _boundModel) && _resolvedIndex != null) {
      return _resolvedIndex;
    }
    _boundModel = model;
    var idx = rootNodeIndex;
    if (idx == null && rootNodeName != null) {
      idx = model.nodeIndexByName(rootNodeName!);
    }
    if (idx == null && model.processingOrder.isNotEmpty) {
      idx = model.processingOrder.first.nodeIndex;
    }
    if (idx == null || !model.nodes.containsKey(idx)) {
      _resolvedIndex = null;
      _chainIndices = null;
      return null;
    }
    _resolvedIndex = idx;

    // Build root-to-target ancestor chain once (`O(depth)`).
    final chain = <int>[];
    int? cur = idx;
    while (cur != null) {
      chain.add(cur);
      cur = model.nodes[cur]?.parentNodeIndex;
    }
    _chainIndices = chain.reversed.toList(growable: false);

    // Compute rest-pose model-space anchor of the tracked root node.
    _chainCombined.setIdentity();
    for (final cIdx in _chainIndices!) {
      _chainCombined.multiply(model.nodes[cIdx]!.transform);
    }
    _anchorModelPos.setValues(
      _chainCombined.storage[12],
      _chainCombined.storage[13],
      _chainCombined.storage[14],
    );
    return idx;
  }

  void _sampleChainInto(
    Model model,
    AnimationState state,
    Matrix4 out, {
    double? overrideNormalizedPhase,
    double? overrideClipClock,
  }) {
    out.setIdentity();
    final chain = _chainIndices;
    if (chain == null) {
      return;
    }
    for (var i = 0; i < chain.length; i++) {
      final node = model.nodes[chain[i]]!;
      state.writeNodeTransform(
        node.nodeIndex,
        node.restTranslation,
        node.restRotation,
        node.restScale,
        node.transform,
        _chainScratch,
        overrideNormalizedPhase: overrideNormalizedPhase,
        overrideClipClock: overrideClipClock,
      );
      out.multiply(_chainScratch);
    }
  }

  double _extractYaw(Matrix4 m) {
    final s = m.storage;
    if (horizontalPlane == RootMotionPlane3D.xz) {
      // Forward axis +Z `(s[8], s[10])` around +Y up.
      return math.atan2(s[8], s[10]);
    }
    // Forward axis +X `(s[0], s[1])` around +Z up.
    return math.atan2(s[1], s[0]);
  }

  static double _shortestAngleDelta(double fromRad, double toRad) {
    var diff = (toRad - fromRad) % (2.0 * math.pi);
    if (diff > math.pi) {
      diff -= 2.0 * math.pi;
    } else if (diff < -math.pi) {
      diff += 2.0 * math.pi;
    }
    return diff;
  }

  /// Captures the pre-step pose if this extractor has not yet been seeded for
  /// the current clip.
  void ensureSeededBeforeTick(Model model, AnimationState state) {
    if (_initialized) {
      return;
    }
    if (_resolveRootNode(model) == null) {
      return;
    }
    _sampleChainInto(model, state, _chainCombined);
    _prevPos.setValues(
      _chainCombined.storage[12],
      _chainCombined.storage[13],
      _chainCombined.storage[14],
    );
    _prevYaw = _extractYaw(_chainCombined);
    _initialized = true;
  }

  /// Computes per-tick local/world root deltas after [state] has advanced.
  void extractStep(
    Model model,
    AnimationState state,
    Matrix4 componentWorldMatrix,
  ) {
    if (_resolveRootNode(model) == null) {
      clearStepDeltas();
      return;
    }
    _sampleChainInto(model, state, _chainCombined);
    _currPos.setValues(
      _chainCombined.storage[12],
      _chainCombined.storage[13],
      _chainCombined.storage[14],
    );
    final currYaw = _extractYaw(_chainCombined);

    if (!_initialized) {
      _prevPos.setFrom(_currPos);
      _prevYaw = currYaw;
      _initialized = true;
      clearStepDeltas();
      return;
    }

    var dx = _currPos.x - _prevPos.x;
    var dy = _currPos.y - _prevPos.y;
    var dz = _currPos.z - _prevPos.z;
    var dYaw = _shortestAngleDelta(_prevYaw, currYaw);

    final wraps = state.lastLoopWrapCount;
    if (wraps != 0) {
      _sampleChainInto(
        model,
        state,
        _chainCombined,
        overrideNormalizedPhase: 0.0,
      );
      _startPos.setValues(
        _chainCombined.storage[12],
        _chainCombined.storage[13],
        _chainCombined.storage[14],
      );
      final startYaw = _extractYaw(_chainCombined);

      _sampleChainInto(
        model,
        state,
        _chainCombined,
        overrideNormalizedPhase: 1.0,
      );
      _endPos.setValues(
        _chainCombined.storage[12],
        _chainCombined.storage[13],
        _chainCombined.storage[14],
      );
      final endYaw = _extractYaw(_chainCombined);

      dx += wraps * (_endPos.x - _startPos.x);
      dy += wraps * (_endPos.y - _startPos.y);
      dz += wraps * (_endPos.z - _startPos.z);
      dYaw += wraps * _shortestAngleDelta(startYaw, endYaw);
    }

    _deltaLocal.setValues(dx, dy, dz);
    _deltaYawRad = dYaw;

    // Transform local displacement vector by upper 3x3 of componentWorldMatrix.
    final w = componentWorldMatrix.storage;
    _deltaWorld.setValues(
      w[0] * dx + w[4] * dy + w[8] * dz,
      w[1] * dx + w[5] * dy + w[9] * dz,
      w[2] * dx + w[6] * dy + w[10] * dz,
    );

    _prevPos.setFrom(_currPos);
    _prevYaw = currYaw;
  }

  /// Locks horizontal and/or vertical root bone translation inside [workspace]
  /// (and shifts all descendant bones identically) before skinning matrices are
  /// computed.
  void applyPoseLock(Model model, ModelPoseWorkspace workspace) {
    if (!lockHorizontalInPlace && !lockVerticalInPlace) {
      return;
    }
    final rootIdx = _resolveRootNode(model);
    if (rootIdx == null) {
      return;
    }
    final rootProcessed = workspace.nodesByIndex[rootIdx];
    if (rootProcessed == null) {
      return;
    }
    final rm = rootProcessed.combinedTransform.storage;
    final px = rm[12];
    final py = rm[13];
    final pz = rm[14];

    var targetX = px;
    var targetY = py;
    var targetZ = pz;
    if (horizontalPlane == RootMotionPlane3D.xz) {
      if (lockHorizontalInPlace) {
        targetX = _anchorModelPos.x;
        targetZ = _anchorModelPos.z;
      }
      if (lockVerticalInPlace) {
        targetY = _anchorModelPos.y;
      }
    } else {
      if (lockHorizontalInPlace) {
        targetX = _anchorModelPos.x;
        targetY = _anchorModelPos.y;
      }
      if (lockVerticalInPlace) {
        targetZ = _anchorModelPos.z;
      }
    }

    final shiftX = targetX - px;
    final shiftY = targetY - py;
    final shiftZ = targetZ - pz;
    if (shiftX.abs() <= 1e-9 && shiftY.abs() <= 1e-9 && shiftZ.abs() <= 1e-9) {
      return;
    }

    rm[12] += shiftX;
    rm[13] += shiftY;
    rm[14] += shiftZ;

    // Propagate translation shift to every descendant of `rootIdx`.
    for (final processed in workspace.orderedNodes) {
      if (_isDescendant(model, processed.node.nodeIndex, rootIdx)) {
        final m = processed.combinedTransform.storage;
        m[12] += shiftX;
        m[13] += shiftY;
        m[14] += shiftZ;
      }
    }
  }

  static bool _isDescendant(Model model, int nodeIdx, int ancestorIdx) {
    if (nodeIdx == ancestorIdx) {
      return false;
    }
    var cur = model.nodes[nodeIdx]?.parentNodeIndex;
    while (cur != null) {
      if (cur == ancestorIdx) {
        return true;
      }
      cur = model.nodes[cur]?.parentNodeIndex;
    }
    return false;
  }
}
