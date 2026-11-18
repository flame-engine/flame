import 'dart:collection';
import 'dart:math' as math;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';

/// Preallocated per-component pose workspace so [Model.evaluateInto] runs every
/// frame with zero heap allocations.
class ModelPoseWorkspace._(this.orderedNodes, this.nodesByIndex) {
  /// Creates a reusable pose workspace sized to [model].
  factory ModelPoseWorkspace.forModel(Model model) {
    final order = model.processingOrder;
    final map = <int, ProcessedNode>{};
    final ordered = <ProcessedNode>[];
    for (final node in order) {
      final joints = <int, List<Matrix4>>{
        for (final entry in node.orderedJointIndicesPerSurface.entries)
          entry.key: List<Matrix4>.generate(
            entry.value.length,
            (_) => Matrix4.identity(),
            growable: false,
          ),
      };
      final processed = ProcessedNode(
        node: node,
        combinedTransform: Matrix4.identity(),
        jointTransforms: joints,
      );
      map[node.nodeIndex] = processed;
      ordered.add(processed);
    }
    return ModelPoseWorkspace._(List.unmodifiable(ordered), map);
  }

  /// Processed nodes in topological dependency order.
  final List<ProcessedNode> orderedNodes;

  /// Processed nodes indexed by `ModelNode.nodeIndex`.
  final Map<int, ProcessedNode> nodesByIndex;

  final Matrix4 _scratchLocal = Matrix4.identity();
}

/// A file-type agnostic representation of a 3D model parsed, including:
/// * a list of nodes
/// * a list of associated animations
class Model {
  final Map<int, ModelNode> nodes;
  final List<ModelAnimation> animations;

  Model({
    required this.nodes,
    required this.animations,
  });

  Model.simple({
    required Mesh mesh,
  }) : nodes = {
         0: ModelNode.simple(
           nodeIndex: 0,
           mesh: mesh,
         ),
       },
       animations = [];

  /// Rest-pose bounding box of the model's meshes in model space.
  Aabb3 get aabb => _aabb ??= _calculateRestBoundingBox();
  Aabb3? _aabb;

  /// Conservative bounding box enclosing the rest pose and all [animations] of
  /// this model, suitable for frustum culling of animated [ModelComponent]s.
  Aabb3 get animatedAabb => _animatedAabb ??= _calculateAnimatedBoundingBox();
  Aabb3? _animatedAabb;

  Aabb3 _calculateRestBoundingBox() {
    final workspace = ModelPoseWorkspace.forModel(this);
    evaluateInto(AnimationState(), workspace);
    final box = Aabb3();
    var any = false;
    final scratch = Aabb3();
    for (final processed in workspace.orderedNodes) {
      final mesh = processed.node.mesh;
      if (mesh == null) {
        continue;
      }
      scratch
        ..setFrom(mesh.aabb)
        ..transform(processed.combinedTransform);
      if (any) {
        box.hull(scratch);
      } else {
        box.setFrom(scratch);
        any = true;
      }
    }
    return box;
  }

  Aabb3 _calculateAnimatedBoundingBox() {
    final box = Aabb3.copy(aabb);
    if (animations.isEmpty || nodes.isEmpty) {
      return box;
    }

    var any = box.min != box.max;
    final workspace = ModelPoseWorkspace.forModel(this);
    final state = AnimationState();
    final scratch = Aabb3();
    final jointMat = Matrix4.identity();

    void hullCurrentPose() {
      for (final processed in workspace.orderedNodes) {
        final mesh = processed.node.mesh;
        if (mesh == null) {
          continue;
        }
        scratch
          ..setFrom(mesh.aabb)
          ..transform(processed.combinedTransform);
        if (any) {
          box.hull(scratch);
        } else {
          box.setFrom(scratch);
          any = true;
        }

        // Expand for skinned surfaces by transforming each surface's rest AABB
        // through its active joint palette matrices (`combined * jointMatrix`).
        final surfaces = mesh.surfaces.toList(growable: false);
        for (final entry in processed.jointTransforms.entries) {
          final surfBox = surfaces[entry.key].aabb;
          for (final jm in entry.value) {
            jointMat
              ..setFrom(processed.combinedTransform)
              ..multiply(jm);
            scratch
              ..setFrom(surfBox)
              ..transform(jointMat);
            box.hull(scratch);
          }
        }
      }
    }

    const samplesPerClip = 8;
    for (final clip in animations) {
      state.startAnimation(clip, mode: AnimationPlayMode.once);
      final duration = math.max(0.0, clip.lastTime);
      final steps = duration > 0 ? samplesPerClip : 0;
      for (var s = 0; s <= steps; s++) {
        state.clock = steps == 0 ? 0.0 : duration * (s / steps);
        evaluateInto(state, workspace);
        hullCurrentPose();
      }
    }
    return box;
  }

  Set<String> get animationNames {
    return {for (final animation in animations) ?animation.name};
  }

  Set<String> get nodeNames {
    return {for (final node in nodes.values) ?node.name};
  }

  /// Finds the index of the first node named [name], or `null`.
  int? nodeIndexByName(String name) {
    for (final entry in nodes.entries) {
      if (entry.value.name == name) {
        return entry.key;
      }
    }
    return null;
  }

  /// Evaluates [animation] (and optional [rootMotion] pose lock and procedural
  /// [modifiers]) into [workspace] with zero heap allocations.
  void evaluateInto(
    AnimationState animation,
    ModelPoseWorkspace workspace, {
    List<BoneModifier3D>? modifiers,
    Matrix4? worldMatrix,
    Matrix4? invWorldMatrix,
    double dt = 0.0,
    RootMotionExtractor3D? rootMotion,
  }) {
    final byIndex = workspace.nodesByIndex;
    final scratch = workspace._scratchLocal;
    for (final processed in workspace.orderedNodes) {
      processed.node.evaluateNodeInto(
        byIndex,
        animation,
        processed.combinedTransform,
        scratch,
      );
    }
    rootMotion?.applyPoseLock(this, workspace);
    if (modifiers != null &&
        modifiers.isNotEmpty &&
        worldMatrix != null &&
        invWorldMatrix != null) {
      for (var i = 0; i < modifiers.length; i++) {
        modifiers[i].apply(this, workspace, worldMatrix, invWorldMatrix, dt);
      }
    }
    for (final processed in workspace.orderedNodes) {
      if (processed.jointTransforms.isNotEmpty) {
        processed.node.updateJointsInPlace(byIndex, processed.jointTransforms);
      }
    }
  }

  /// Evaluates [animation] and returns a fresh map of [ProcessedNode]s.
  ///
  /// For per-frame rendering without allocations, prefer creating a
  /// [ModelPoseWorkspace] once and calling [evaluateInto].
  Map<int, ProcessedNode> processNodes(AnimationState animation) {
    final processedNodes = <int, ProcessedNode>{};
    for (final node in processingOrder) {
      node.processNode(processedNodes, animation);
    }
    return processedNodes;
  }

  /// The [nodes] ordered so that every node comes after its dependencies.
  List<ModelNode> get processingOrder => _order ??= _orderNodes();
  List<ModelNode>? _order;

  List<ModelNode> _orderNodes() {
    final order = <ModelNode>[];

    final inDegree = <int, int>{};
    final adjacencyMap = <int, Set<int>>{};

    for (final node in nodes.values) {
      final index = node.nodeIndex;
      final deps = node.dependencies;
      inDegree[index] = deps.length;
      for (final dep in deps) {
        (adjacencyMap[dep] ??= {}).add(index);
      }
    }

    final queue = Queue<int>.from(
      [
        for (final node in nodes.values)
          if (inDegree[node.nodeIndex] == 0) node.nodeIndex,
      ],
    );

    while (queue.isNotEmpty) {
      final index = queue.removeFirst();
      order.add(nodes[index]!);
      final adjacency = adjacencyMap[index] ?? {};
      for (final dependency in adjacency) {
        inDegree[dependency] = inDegree[dependency]! - 1;
        if (inDegree[dependency] == 0) {
          queue.add(dependency);
        }
      }
    }

    if (order.length != nodes.length) {
      throw StateError('Failed to process all nodes');
    }

    return order;
  }
}
