import 'package:behavior_tree/behavior_tree.dart';

/// The valid values for status of a node.
enum NodeStatus {
  /// Indicates that the node has not been ticked yet.
  notStarted,

  /// Indicates that the node is running.
  running,

  /// Indicates that the node has completed successfully.
  success,

  /// Indicates that the node has failed.
  failure,
}

/// An interface which all the nodes implement.
///
/// Some examples are [Selector], [Sequence], [Inverter] and [Limiter].
abstract interface class INode {
  /// Returns the current status of this node.
  NodeStatus get status;

  /// Sets the status of this node.
  set status(NodeStatus value);

  /// Updates the node and re-evaluates its status.
  void tick();

  /// Resets the node to its initial state.
  void reset();
}
