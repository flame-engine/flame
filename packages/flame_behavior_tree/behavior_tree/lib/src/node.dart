import 'package:behavior_tree/behavior_tree.dart';

/// The valid values for status of a node.
enum NodeStatus {
  /// Indicates that the node is running.
  running,

  /// Indicates that the node has completed succesfully.
  success,

  /// Indicates that the node has failed.
  failure,
}

/// An interface which all the nodes implement.
///
/// Some examples are [Selector], [Sequence], [Inverter] and [Limiter].
abstract interface class Node {
  /// Returns the current status of this node.
  NodeStatus get status;

  /// Updates the node and re-evaluates its status.
  void tick();
}
