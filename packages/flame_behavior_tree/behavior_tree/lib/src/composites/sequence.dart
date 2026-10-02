import 'package:behavior_tree/behavior_tree.dart';

/// A composite node that stops at its first successful child node.
class Sequence({List<NodeInterface>? children})
    extends BaseNode
    implements NodeInterface {
  /// Creates a sequence node for given [children] nodes.
  this {
    _children.forEach(setParent);
  }

  final List<NodeInterface> _children = children ?? <NodeInterface>[];

  @override
  void tick() {
    for (final node in _children) {
      node.tick();

      if (node.status != NodeStatus.success) {
        status = node.status;
        return;
      }
    }
    status = NodeStatus.success;
  }

  @override
  void reset() {
    for (final node in _children) {
      node.reset();
    }
    super.reset();
  }
}
