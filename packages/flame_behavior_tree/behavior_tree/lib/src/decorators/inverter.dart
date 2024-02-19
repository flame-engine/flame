import 'package:behavior_tree/src/node.dart';

/// A decorator node that inverts [child]'s status if it is not
/// [NodeStatus.running].
class Inverter implements Node {
  /// Creates an inverter node for given [child] node.
  Inverter(this.child);

  var _nodeStatus = NodeStatus.running;

  /// The child node whose status needs to be inverted.
  final Node child;

  @override
  NodeStatus get status => _nodeStatus;

  @override
  void tick() {
    child.tick();
    switch (child.status) {
      case NodeStatus.running:
        _nodeStatus = NodeStatus.running;
      case NodeStatus.success:
        _nodeStatus = NodeStatus.failure;
      case NodeStatus.failure:
        _nodeStatus = NodeStatus.success;
    }
  }
}
