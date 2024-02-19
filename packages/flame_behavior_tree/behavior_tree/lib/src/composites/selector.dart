import 'package:behavior_tree/src/node.dart';

/// A composite node that stops at its first non-failing child node.
class Selector implements Node {
  /// Creates a selector node for given [children] nodes.
  Selector({List<Node>? children}) : _children = children ?? <Node>[];

  final List<Node> _children;
  var _nodeStatus = NodeStatus.running;

  @override
  NodeStatus get status => _nodeStatus;

  @override
  void tick() {
    for (final node in _children) {
      node.tick();

      if (node.status != NodeStatus.failure) {
        _nodeStatus = node.status;
        return;
      }
    }
    _nodeStatus = NodeStatus.failure;
  }
}
