import 'package:behavior_tree/src/node.dart';

/// A composite node that stops at its first succesful child node.
class Sequence implements Node {
  /// Creates a sequence node for given [children] nodes.
  Sequence({List<Node>? children}) : _children = children ?? <Node>[];

  final List<Node> _children;
  var _nodeStatus = NodeStatus.running;

  @override
  NodeStatus get status => _nodeStatus;

  @override
  void tick() {
    for (final node in _children) {
      node.tick();
      if (node.status != NodeStatus.success) {
        _nodeStatus = node.status;
        return;
      }
    }
    _nodeStatus = NodeStatus.success;
  }
}
