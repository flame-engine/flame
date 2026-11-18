import 'dart:ui' show Color, VoidCallback;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/src/model/animation_state.dart';
import 'package:flame_3d/src/model/blend_space_3d.dart';
import 'package:flame_3d/src/model/model.dart';
import 'package:flame_3d/src/model/model_animation.dart';
import 'package:flame_3d/src/model/procedural_rigging_3d.dart';
import 'package:flame_3d/src/model/root_motion_3d.dart';

/// Controls how [ModelComponent] advances clocks and evaluates skeletal poses
/// when culled outside the camera frustum.
enum OffscreenAnimationPolicy() {
  /// Evaluates the full skeletal pose on every [ModelComponent.update] tick
  /// whenever the animation changes (default, 100% backward-compatible).
  always,

  /// Advances clocks and dispatches [AnimationEvent3D]s every tick, but defers
  /// matrix hierarchy & skinning evaluation until [ModelComponent.draw],
  /// [ModelComponent.nodeTransform], `BoneSocket3D`, or
  /// [ModelComponent.raycast] requests the pose.
  tickOnlyEvaluateWhenVisible,

  /// Pauses clock advancement completely unless [ModelComponent.draw] ran on
  /// the preceding rendered frame.
  pauseWhenOffscreen,
}

/// A component wrapper over a 3D [Model], using an allocation-free
/// [ModelPoseWorkspace] and [AnimationState] to evaluate animations,
/// crossfades, 1D/2D blend spaces, root motion, and attached `BoneSocket3D`
/// children.
class ModelComponent({
  required final Model model,
  var Color color = const Color(0xFFFFFFFF),
  Vector4? instanceData,
  var OffscreenAnimationPolicy offscreenPolicy =
      OffscreenAnimationPolicy.always,
  var RootMotionExtractor3D? rootMotion,
  var AnimationEventCallback3D? onAnimationEvent,
  super.position,
  super.rotation,
  super.scale,
  super.children,
  super.castsShadows,
}) extends Object3D {
  this {
    _animation.addEventListener(_forwardAnimationEvent);
  }

  /// Four floats of per-instance data forwarded to materials.
  final Vector4 instanceData = instanceData?.clone() ?? Vector4.zero();

  final Set<int> _hiddenNodes = {};
  final AnimationState _animation = AnimationState();
  late final ModelPoseWorkspace _workspace = ModelPoseWorkspace.forModel(model);
  bool _poseDirty = true;
  double _pendingModifierDt = 0.0;
  bool _drawnSinceLastUpdate = false;
  int _poseEvaluationsCount = 0;

  /// Procedural post-animation bone modifiers (`SpringBone3D`,
  /// `LookAtConstraint3D`, `TwoBoneIkConstraint3D`) applied every frame.
  final List<BoneModifier3D> boneModifiers = [];

  final Matrix4 _invWorld = Matrix4.identity();
  final List<double> _morphScratch = [];

  void _forwardAnimationEvent(AnimationEvent3D event) {
    onAnimationEvent?.call(event);
  }

  /// Underlying animation state (supports speed, playback mode, crossfades,
  /// 1D/2D blend spaces, events, and masked `layers`).
  AnimationState get animationState => _animation;

  /// Total number of times [evaluatePose] has recomputed this component's
  /// node hierarchy and skinning matrices.
  int get poseEvaluationsCount => _poseEvaluationsCount;

  /// Resets [poseEvaluationsCount] back to `0` (useful for profiling/tests).
  void resetPoseEvaluationsCount() {
    _poseEvaluationsCount = 0;
  }

  /// Current 1D parameter driving [AnimationState.activeBlendSpace1D].
  double get blendParameter1D => _animation.blendParameter1D;
  set blendParameter1D(double value) {
    if (_animation.blendParameter1D != value) {
      _animation.blendParameter1D = value;
      _markPoseChanged();
    }
  }

  /// Current 2D parameter driving [AnimationState.activeBlendSpace2D].
  Vector2 get blendParameter2D => _animation.blendParameter2D;
  set blendParameter2D(Vector2 value) {
    if (_animation.blendParameter2D != value) {
      _animation.blendParameter2D = value;
      _markPoseChanged();
    }
  }

  @override
  Aabb3? computeLocalAabb() => model.animatedAabb;

  final Matrix4 _nodeTransform = Matrix4.identity();

  /// Ensures the node transforms reflect the current [animationState] clock,
  /// optional [rootMotion] pose lock, and any [boneModifiers].
  ModelPoseWorkspace evaluatePose() {
    if (_poseDirty) {
      _poseDirty = false;
      _poseEvaluationsCount++;
      final dt = _pendingModifierDt;
      _pendingModifierDt = 0.0;
      if (boneModifiers.isNotEmpty) {
        final w = worldTransformMatrix;
        _invWorld.copyInverse(w);
        model.evaluateInto(
          _animation,
          _workspace,
          modifiers: boneModifiers,
          worldMatrix: w,
          invWorldMatrix: _invWorld,
          dt: dt,
          rootMotion: rootMotion,
        );
      } else {
        model.evaluateInto(
          _animation,
          _workspace,
          rootMotion: rootMotion,
        );
      }
      _evaluateAnimatedMorphTargets();
    }
    return _workspace;
  }

  void _evaluateAnimatedMorphTargets() {
    if (!_animation.hasActiveEvaluation && _animation.layers.isEmpty) {
      return;
    }

    for (final node in model.nodes.values) {
      final mesh = node.mesh;
      if (mesh == null) {
        continue;
      }
      final targetCount = _animation.sampleNodeMorphWeights(
        node.nodeIndex,
        _morphScratch,
      );
      if (targetCount <= 0) {
        continue;
      }
      for (final surface in mesh.surfaces) {
        if (surface.morphTargets.isNotEmpty) {
          surface.applyMorphWeights(_morphScratch);
        }
      }
    }
  }

  /// Applies [weights] directly to all morph-enabled surfaces of [nodeName]
  /// (or to every morph-enabled surface in the model when [nodeName] is
  /// `null`).
  void setMorphWeights(List<double> weights, {String? nodeName}) {
    for (final node in model.nodes.values) {
      if (nodeName != null && node.name != nodeName) {
        continue;
      }
      final mesh = node.mesh;
      if (mesh == null) {
        continue;
      }
      for (final surface in mesh.surfaces) {
        if (surface.morphTargets.isNotEmpty) {
          surface.applyMorphWeights(weights);
        }
      }
    }
    worldOrNull?.markSceneDirty(shadows: castsShadows);
  }

  /// Creates and attaches a masked [AnimationLayer3D] affecting [boneNames]
  /// (and all descendant bones when [includeDescendants] is `true`).
  AnimationLayer3D addOverlayLayer({
    required Set<String> boneNames,
    bool includeDescendants = true,
    double weight = 1.0,
  }) {
    final indices = <int>{};
    for (final name in boneNames) {
      final idx = model.nodeIndexByName(name);
      if (idx != null) {
        indices.add(idx);
      }
    }
    if (includeDescendants && indices.isNotEmpty) {
      for (final node in model.processingOrder) {
        final p = node.parentNodeIndex;
        if (p != null && indices.contains(p)) {
          indices.add(node.nodeIndex);
        }
      }
    }
    final layer = AnimationLayer3D(nodeIndices: indices, weight: weight);
    _animation.layers.add(layer);
    _markPoseChanged();
    return layer;
  }

  /// Combined model-space transform of [nodeIndex] in the current pose, or
  /// `null` if no such node exists.
  Matrix4? nodeTransform(int nodeIndex) {
    return evaluatePose().nodesByIndex[nodeIndex]?.combinedTransform;
  }

  /// Combined model-space transform of the node named [name] in the current
  /// pose, or `null` if no such node exists.
  Matrix4? nodeTransformByName(String name) {
    final index = model.nodeIndexByName(name);
    return index == null ? null : nodeTransform(index);
  }

  @override
  void draw(covariant RenderContext3D context) {
    _drawnSinceLastUpdate = true;
    final workspace = evaluatePose();
    context.beginDepthPrepassGroup();
    try {
      for (final node in workspace.orderedNodes) {
        if (_hiddenNodes.contains(node.node.nodeIndex)) {
          continue;
        }

        final mesh = node.node.mesh;
        if (mesh != null) {
          _nodeTransform
            ..setFrom(worldTransformMatrix)
            ..multiply(node.combinedTransform);
          context.drawMesh(
            mesh,
            transform: _nodeTransform,
            color: color,
            instanceData: instanceData,
            jointTransforms: node.jointTransforms,
          );
        }
      }
    } finally {
      context.endDepthPrepassGroup();
    }
  }

  @override
  RayHit3D? raycast(
    Ray worldRay, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
  }) {
    final workspace = evaluatePose();
    RayHit3D? best;
    var limit = maxDistance;
    for (final node in workspace.orderedNodes) {
      if (_hiddenNodes.contains(node.node.nodeIndex)) {
        continue;
      }
      final mesh = node.node.mesh;
      if (mesh == null) {
        continue;
      }
      _nodeTransform
        ..setFrom(worldTransformMatrix)
        ..multiply(node.combinedTransform);
      final hit = RayHit3D.intersectMesh(
        owner: this,
        mesh: mesh,
        modelMatrix: _nodeTransform,
        worldRay: worldRay,
        maxDistance: limit,
        cullMode: cullMode,
      );
      if (hit != null && hit.distance < limit) {
        limit = hit.distance;
        best = hit;
      }
    }
    return best;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final wasDrawn = _drawnSinceLastUpdate;
    _drawnSinceLastUpdate = false;

    if (offscreenPolicy == OffscreenAnimationPolicy.pauseWhenOffscreen &&
        !wasDrawn) {
      rootMotion?.clearStepDeltas();
      return;
    }

    final extractor = rootMotion;
    extractor?.ensureSeededBeforeTick(model, _animation);

    final animChanged = _animation.update(dt);
    final hasModifiers = boneModifiers.any((m) => m.weight > 0.0);

    if (extractor != null) {
      if (animChanged) {
        extractor.extractStep(model, _animation, worldTransformMatrix);
        if (extractor.applyToComponentTransform) {
          position.add(extractor.deltaPositionWorld);
          if (extractor.deltaYawRad.abs() > 1e-9) {
            final up = extractor.horizontalPlane == RootMotionPlane3D.xz
                ? _upY
                : _upZ;
            _yawDeltaQ.setAxisAngle(up, extractor.deltaYawRad);
            rotation
              ..setFrom(_yawDeltaQ * rotation)
              ..normalize();
          }
        }
      } else {
        extractor.clearStepDeltas();
      }
    }

    if (animChanged || (hasModifiers && dt > 0.0)) {
      _pendingModifierDt += dt;
      _poseDirty = true;
      if (offscreenPolicy == OffscreenAnimationPolicy.always) {
        evaluatePose();
      }
      worldOrNull?.markSceneDirty(shadows: castsShadows);
    }
  }

  Set<String> get animationNames => model.animationNames;

  /// Activates a 1D [BlendSpace1D] on this component's [animationState].
  void playBlendSpace1D(
    BlendSpace1D space, {
    double initialValue = 0.0,
    bool resetClock = true,
  }) {
    if (resetClock) {
      rootMotion?.reset();
    }
    _animation.playBlendSpace1D(
      space,
      initialValue: initialValue,
      resetClock: resetClock,
    );
    _markPoseChanged();
  }

  /// Activates a 2D [BlendSpace2D] on this component's [animationState].
  void playBlendSpace2D(
    BlendSpace2D space, {
    Vector2? initialValue,
    bool resetClock = true,
  }) {
    if (resetClock) {
      rootMotion?.reset();
    }
    _animation.playBlendSpace2D(
      space,
      initialValue: initialValue,
      resetClock: resetClock,
    );
    _markPoseChanged();
  }

  void playAnimationByName(
    String name, {
    bool resetClock = true,
    AnimationPlayMode mode = AnimationPlayMode.loop,
    VoidCallback? onComplete,
  }) {
    final animation = model.animations.where((e) => e.name == name).firstOrNull;
    if (animation == null) {
      throw ArgumentError('No animation with name $name');
    }
    if (resetClock) {
      rootMotion?.reset();
    }
    _animation.startAnimation(
      animation,
      resetClock: resetClock,
      mode: mode,
      onComplete: onComplete,
    );
    _markPoseChanged();
  }

  void playAnimationByIndex(
    int index, {
    bool resetClock = true,
    AnimationPlayMode mode = AnimationPlayMode.loop,
    VoidCallback? onComplete,
  }) {
    final animation = model.animations[index];
    if (resetClock) {
      rootMotion?.reset();
    }
    _animation.startAnimation(
      animation,
      resetClock: resetClock,
      mode: mode,
      onComplete: onComplete,
    );
    _markPoseChanged();
  }

  /// Smoothly crossfades to the animation named [name] over [duration] seconds.
  void crossFadeToByName(
    String name, {
    double duration = 0.25,
    bool resetClock = true,
    AnimationPlayMode mode = AnimationPlayMode.loop,
    VoidCallback? onComplete,
  }) {
    final animation = model.animations.where((e) => e.name == name).firstOrNull;
    if (animation == null) {
      throw ArgumentError('No animation with name $name');
    }
    if (resetClock) {
      rootMotion?.reset();
    }
    _animation.crossFadeTo(
      animation,
      duration: duration,
      resetClock: resetClock,
      mode: mode,
      onComplete: onComplete,
    );
    _markPoseChanged();
  }

  /// Smoothly crossfades to the animation at [index] over [duration] seconds.
  void crossFadeToByIndex(
    int index, {
    double duration = 0.25,
    bool resetClock = true,
    AnimationPlayMode mode = AnimationPlayMode.loop,
    VoidCallback? onComplete,
  }) {
    final animation = model.animations[index];
    if (resetClock) {
      rootMotion?.reset();
    }
    _animation.crossFadeTo(
      animation,
      duration: duration,
      resetClock: resetClock,
      mode: mode,
      onComplete: onComplete,
    );
    _markPoseChanged();
  }

  void stopAnimation() {
    rootMotion?.reset();
    _animation.startAnimation(null);
    _markPoseChanged();
  }

  void hideNodeByName(String name, {bool hidden = true}) {
    final node = model.nodes.entries.firstWhere((e) => e.value.name == name);
    if (hidden) {
      _hiddenNodes.add(node.key);
    } else {
      _hiddenNodes.remove(node.key);
    }
    worldOrNull?.markSceneDirty(shadows: castsShadows);
  }

  void _markPoseChanged() {
    _poseDirty = true;
    worldOrNull?.markSceneDirty(shadows: castsShadows);
  }

  static final Vector3 _upY = Vector3(0, 1, 0);
  static final Vector3 _upZ = Vector3(0, 0, 1);
  static final Quaternion _yawDeltaQ = Quaternion.identity();
}
