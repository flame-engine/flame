import 'package:behavior_tree/behavior_tree.dart';

/// A decorator node that inverts [child]'s status if it is not
/// [NodeStatus.running].
class Inverter extends BaseNode implements NodeInterface {
  /// Creates an inverter node for given [child] node.
  Inverter(this.child) {
    _invertStatus();
  }

  /// The child node whose status needs to be inverted.
  final NodeInterface child;

  @override
  void tick() {
    child.tick();
    _invertStatus();
  }

  void _invertStatus() {
    switch (child.status) {
      case NodeStatus.notStarted:
        status = NodeStatus.notStarted;
      case NodeStatus.running:
        status = NodeStatus.running;
      case NodeStatus.success:
        status = NodeStatus.failure;
      case NodeStatus.failure:
        status = NodeStatus.success;
    }
  }

  @override
  void reset() {
    super.reset();
    child.reset();
    _invertStatus();
  }
}
