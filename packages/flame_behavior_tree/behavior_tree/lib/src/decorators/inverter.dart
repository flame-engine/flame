import 'package:behavior_tree/behavior_tree.dart';

/// A decorator node that inverts [child]'s status if it is not
/// [NodeStatus.running].
class Inverter extends BaseNode implements NodeInterface {
  /// Creates an inverter node for given [child] node.
  Inverter(this.child) {
    setParent(child);
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
    status = switch (child.status) {
      NodeStatus.notStarted => NodeStatus.notStarted,
      NodeStatus.running => NodeStatus.running,
      NodeStatus.success => NodeStatus.failure,
      NodeStatus.failure => NodeStatus.success,
    };
  }

  @override
  void reset() {
    super.reset();
    child.reset();
    _invertStatus();
  }
}
