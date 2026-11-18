import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/model/animation_state.dart';

/// A node wraps over a mesh as part of a 3D model, including its joints and
/// local transformations.
class ModelNode {
  final String? name;
  final int nodeIndex;
  final int? parentNodeIndex;
  final Matrix4 transform;
  final Mesh? mesh;
  final Map<int, ModelJoint> joints;

  /// Rest-pose TRS components decomposed once from [transform] for
  /// allocation-free animation blending.
  final Vector3 restTranslation = Vector3.zero();
  final Quaternion restRotation = Quaternion.identity();
  final Vector3 restScale = Vector3.all(1.0);

  ModelNode({
    required this.name,
    required this.nodeIndex,
    required this.parentNodeIndex,
    required this.transform,
    required this.mesh,
    required this.joints,
  }) {
    transform.decompose(restTranslation, restRotation, restScale);
  }

  List<int> get dependencies => [
    ?parentNodeIndex,
    for (final joint in joints.values) joint.nodeIndex,
  ];

  ModelNode.simple({
    required this.nodeIndex,
    required this.mesh,
  }) : name = null,
       parentNodeIndex = null,
       transform = Matrix4.identity(),
       joints = {};

  /// Ordered global joint indices per surface index, computed once on first
  /// access so per-frame skinning never sorts or allocates lists.
  late final Map<int, List<int>> orderedJointIndicesPerSurface =
      _buildOrderedJointIndices();

  Map<int, List<int>> _buildOrderedJointIndices() {
    final result = <int, List<int>>{};
    final surfaces = mesh?.surfaces;
    if (surfaces == null) {
      return result;
    }
    var index = 0;
    for (final surface in surfaces) {
      final map = surface.jointMap;
      if (map != null) {
        final entries = map.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        final ordered = List<int>.generate(
          entries.length,
          (i) => entries[i].key,
          growable: false,
        );
        for (final jointIndex in ordered) {
          if (!joints.containsKey(jointIndex)) {
            throw StateError('Missing joint $jointIndex');
          }
        }
        result[index] = ordered;
      }
      index++;
    }
    return result;
  }

  void processNode(
    Map<int, ProcessedNode> processedNodes,
    AnimationState animation,
  ) {
    final resultMatrix = Matrix4.identity();
    evaluateNodeInto(processedNodes, animation, resultMatrix, _scratchLocal);
    final jointTransforms = computeJointsPerSurface(processedNodes);

    processedNodes[nodeIndex] = ProcessedNode(
      node: this,
      combinedTransform: resultMatrix,
      jointTransforms: jointTransforms,
    );
  }

  /// Writes `parentCombined * animatedLocal` into [combinedOut] without
  /// allocating.
  void evaluateNodeInto(
    Map<int, ProcessedNode> processedNodes,
    AnimationState animation,
    Matrix4 combinedOut,
    Matrix4 localScratch,
  ) {
    animation.writeNodeTransform(
      nodeIndex,
      restTranslation,
      restRotation,
      restScale,
      transform,
      localScratch,
    );
    final parentIdx = parentNodeIndex;
    if (parentIdx != null) {
      combinedOut
        ..setFrom(processedNodes[parentIdx]!.combinedTransform)
        ..multiply(localScratch);
    } else {
      combinedOut.setFrom(localScratch);
    }
  }

  /// Updates the preallocated [jointTransformsOut] matrices in place without
  /// allocating.
  void updateJointsInPlace(
    Map<int, ProcessedNode> processedNodes,
    Map<int, List<Matrix4>> jointTransformsOut,
  ) {
    for (final entry in orderedJointIndicesPerSurface.entries) {
      final ordered = entry.value;
      final outList = jointTransformsOut[entry.key]!;
      for (var i = 0; i < ordered.length; i++) {
        final joint = joints[ordered[i]]!;
        final jointNode = processedNodes[joint.nodeIndex];
        final m = outList[i];
        if (jointNode != null) {
          m
            ..setFrom(jointNode.combinedTransform)
            ..multiply(joint.inverseBindMatrix);
        } else {
          m.setFrom(joint.inverseBindMatrix);
        }
      }
    }
  }

  Map<int, List<Matrix4>> computeJointsPerSurface(
    Map<int, ProcessedNode> processedNodes,
  ) {
    final jointTransformsPerSurface = <int, List<Matrix4>>{};
    for (final entry in orderedJointIndicesPerSurface.entries) {
      final ordered = entry.value;
      final list = List<Matrix4>.generate(ordered.length, (i) {
        final joint = joints[ordered[i]]!;
        final jointNode = processedNodes[joint.nodeIndex];
        final out = Matrix4.identity();
        if (jointNode != null) {
          out
            ..setFrom(jointNode.combinedTransform)
            ..multiply(joint.inverseBindMatrix);
        } else {
          out.setFrom(joint.inverseBindMatrix);
        }
        return out;
      }, growable: false);
      jointTransformsPerSurface[entry.key] = list;
    }
    return jointTransformsPerSurface;
  }

  static final Matrix4 _scratchLocal = Matrix4.identity();
}

/// A single joint inside a [ModelNode].
class ModelJoint({
  required final int nodeIndex,
  required final Matrix4 inverseBindMatrix,
});

/// A post-processed node including the final transforms after animations are
/// applied.
class ProcessedNode({
  required final ModelNode node,
  required final Matrix4 combinedTransform,
  required final Map<int, List<Matrix4>> jointTransforms,
});
