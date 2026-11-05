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
    for (final node in _processingOrder) {
      node.processNode(processedNodes, animation);
    }
    return processedNodes;
  }

  /// The [nodes] ordered so that every node comes after its dependencies.
  ///
  /// The order only depends on the node hierarchy, so like [aabb] it is
  /// computed once, on the first call to [processNodes].
  List<ModelNode> get _processingOrder => _order ??= _orderNodes();
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
