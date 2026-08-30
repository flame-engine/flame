part of 'component.dart';

/// A mixin for components that manage the update traversal of their own
/// subtree, instead of the engine's standard "update self, then update every
/// child in priority order" recursion.
///
/// The engine's flattened update pass treats every [CustomTraversal]
/// component as a barrier: it calls the component's [updateSubtree] and lets
/// that method drive the subtree.
///
/// Override [updateSubtree] to customize the traversal, and call
/// `super.updateSubtree` to run the standard traversal, possibly with a
/// modified time delta:
/// ```dart
/// class SlowMotionArea extends Component with CustomTraversal {
///   @override
///   void updateSubtree(double dt) => super.updateSubtree(dt / 2);
/// }
/// ```
///
/// Mixins that build on top of this (like `HasTimeScale`) are declared
/// `on CustomTraversal`, so that their `super.updateSubtree` chains through
/// any other custom traversal applied before them. Their users mix in
/// [CustomTraversal] first: `with CustomTraversal, HasTimeScale`.
mixin CustomTraversal on Component {
  /// Updates this component and its subtree.
  ///
  /// The default implementation performs the engine's standard traversal:
  /// update this component, then update the children in priority order.
  void updateSubtree(double dt) => _defaultUpdateSubtree(dt);
}
