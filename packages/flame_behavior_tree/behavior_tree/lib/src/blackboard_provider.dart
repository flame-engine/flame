import 'package:behavior_tree/behavior_tree.dart';

/// An interface for components that provide a blackboard to behavior trees.
///
/// This should typically be implemented by game components that have behavior
/// trees, allowing the tree root to fetch the blackboard from its owning
/// component.
abstract interface class BlackboardProvider {
  /// Gets the blackboard for this provider.
  Blackboard? get blackboard;
}
