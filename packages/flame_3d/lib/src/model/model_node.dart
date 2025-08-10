import 'package:collection/collection.dart';
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

  ModelNode({
    required this.name,
    required this.nodeIndex,
    required this.parentNodeIndex,
    required this.transform,
    required this.mesh,
    required this.joints,
  });

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

  void processNode(
    Map<int, ProcessedNode> processedNodes,
    AnimationState animation,
  ) {
    final resultMatrix = Matrix4.identity();

    // parent
    final parentNodeIndex = this.parentNodeIndex;
    if (parentNodeIndex != null) {
      resultMatrix.multiply(processedNodes[parentNodeIndex]!.combinedTransform);
    }

    // local + animation
    final localTransform = animation.maybeTransform(nodeIndex, transform);
    resultMatrix.multiply(localTransform);

    final jointTransforms = computeJointsPerSurface(processedNodes);

    processedNodes[nodeIndex] = ProcessedNode(
      node: this,
      combinedTransform: resultMatrix,
      jointTransforms: jointTransforms,
    );
  }

  Map<int, List<Matrix4>> computeJointsPerSurface(
    Map<int, ProcessedNode> processedNodes,
  ) {
    final jointTransformsPerSurface = <int, List<Matrix4>>{};
    final surfaces = mesh?.surfaces ?? [];
    for (final (index, surface) in surfaces.indexed) {
      final globalToLocalJointMap = surface.jointMap;
      if (globalToLocalJointMap == null) {
        continue;
      }

      final jointTransforms =
          (globalToLocalJointMap.entries..sortedBy((e) => e.value))
              .map((e) => e.key)
              .map((jointIndex) {
                final joint = joints[jointIndex];
                if (joint == null) {
                  throw StateError('Missing joint $jointIndex');
                }

                final jointNodeIndex = joint.nodeIndex;
                final jointNode = processedNodes[jointNodeIndex];

                final transform = Matrix4.identity()
                  ..multiply(jointNode?.combinedTransform ?? Matrix4.identity())
                  ..multiply(joint.inverseBindMatrix);

                return transform;
              })
              .toList();

      jointTransformsPerSurface[index] = jointTransforms;
    }

    return jointTransformsPerSurface;
  }
}

/// A single join inside a [ModelNode].
class ModelJoint {
  final int nodeIndex;
  final Matrix4 inverseBindMatrix;

  ModelJoint({
    required this.nodeIndex,
    required this.inverseBindMatrix,
  });
}

/// A post-processed node including the final transforms after animations are
/// applied.
class ProcessedNode {
  final ModelNode node;
  final Matrix4 combinedTransform;
  // for each surface within the node's mesh, a list of up to 4 joint transforms
  // with localized indexes according to the surface's localJoints
  final Map<int, List<Matrix4>> jointTransforms;

  ProcessedNode({
    required this.node,
    required this.combinedTransform,
    required this.jointTransforms,
  });
}
