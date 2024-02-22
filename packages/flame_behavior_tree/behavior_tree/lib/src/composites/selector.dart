import 'package:behavior_tree/behavior_tree.dart';

/// A composite node that stops at its first non-failing child node.
class Selector extends BaseNode implements INode {
  /// Creates a selector node for given [children] nodes.
  Selector({List<INode>? children}) : _children = children ?? <INode>[];

  final List<INode> _children;

  @override
  void tick() {
    for (final node in _children) {
      node.tick();

      if (node.status != NodeStatus.failure) {
        status = node.status;
        return;
      }
    }
    status = NodeStatus.failure;
  }

  @override
  void reset() {
    for (final node in _children) {
      node.reset();
    }
    super.reset();
  }
}
