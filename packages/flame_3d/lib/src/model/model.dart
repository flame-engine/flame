import 'dart:collection';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';

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

  Aabb3 get aabb => _aabb ??= _calculateBoundingBox();
  Aabb3? _aabb;

  Aabb3 _calculateBoundingBox() {
    final box = Aabb3();
    for (final entry in nodes.entries) {
      final mesh = entry.value.mesh;
      if (mesh != null) {
        box.hull(mesh.aabb);
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

  Map<int, ProcessedNode> processNodes(AnimationState animation) {
    final processedNodes = <int, ProcessedNode>{};

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
      final node = nodes[index]!;
      node.processNode(processedNodes, animation);
      final adjacency = adjacencyMap[index] ?? {};
      for (final dependency in adjacency) {
        inDegree[dependency] = inDegree[dependency]! - 1;
        if (inDegree[dependency] == 0) {
          queue.add(dependency);
        }
      }
    }

    if (processedNodes.length != nodes.length) {
      throw StateError('Failed to process all nodes');
    }

    return processedNodes;
  }
}
