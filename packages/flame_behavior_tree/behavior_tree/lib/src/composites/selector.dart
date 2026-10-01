import 'package:behavior_tree/behavior_tree.dart';

/// A composite node that stops at its first non-failing child node.
class Selector({List<NodeInterface>? children})
    extends BaseNode
    implements NodeInterface {
  /// Creates a selector node for given [children] nodes.
  this {
    _children.forEach(setParent);
  }

  final List<NodeInterface> _children = children ?? <NodeInterface>[];

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
