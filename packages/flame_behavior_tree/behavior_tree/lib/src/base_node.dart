import 'package:behavior_tree/behavior_tree.dart';
import 'package:meta/meta.dart';

/// A base class for all the nodes.
abstract class BaseNode implements NodeInterface {
  NodeStatus _status = NodeStatus.notStarted;

  /// The parent node in the behavior tree.
  ///
  /// This is set automatically when nodes are added as children to composite
  /// or decorator nodes. It enables nodes to query up the tree for the
  /// blackboard without needing explicit propagation.
  BaseNode? _parent;

  /// The blackboard provider (only set on root node).
  ///
  /// This is typically set by components that implement [BlackboardProvider],
  /// such as those using the HasBehaviorTree mixin. Only the root node needs
  /// this set; child nodes will query up the tree.
  BlackboardProvider? _blackboardProvider;

  /// Gets the blackboard by querying up the tree hierarchy.
  ///
  /// Child nodes ask their parent for the blackboard, and the root node
  /// fetches it from its [BlackboardProvider]. This means the blackboard
  /// lives in the component, not in the tree nodes themselves.
  ///
  /// Example:
  /// In a Flame component with HasBehaviorTree
  /// ```dart
  /// blackboard = Blackboard();
  /// blackboard.set('health', 100);
  /// treeRoot = Sequence(children: [...]);
  /// ```
  /// All nodes in the tree can now access the blackboard
  Blackboard? get blackboard {
    // If we have a provider (we're the root), get it from there.
    // Otherwise, query our parent.
    return _blackboardProvider?.blackboard ?? _parent?.blackboard;
  }

  /// Sets the blackboard provider on this node (only used on root).
  ///
  /// This is called automatically by mixins like HasBehaviorTree.
  set blackboardProvider(BlackboardProvider? provider) {
    _blackboardProvider = provider;
  }

  @override
  NodeStatus get status => _status;

  @override
  set status(NodeStatus value) {
    _status = value;
  }

  @override
  @mustCallSuper
  void reset() {
    _status = NodeStatus.notStarted;
  }

  /// Internal method to set parent relationship when adding children.
  @protected
  void setParent(NodeInterface child) {
    if (child is BaseNode) {
      child._parent = this;
    }
  }
}
