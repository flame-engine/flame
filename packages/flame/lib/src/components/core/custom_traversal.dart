import 'package:flame/src/components/core/component.dart';

/// A mixin for components that manage the update traversal of their own
/// subtree, instead of the engine's standard "update self, then update every
/// child in priority order" recursion.
///
/// Mixing this in is both the capability and the barrier marker: the engine's
/// flattened update pass treats every [CustomTraversal] component as a
/// barrier, calls its [updateSubtree], and lets that method drive the
/// subtree. This is also why [Component.updateTree] is non-virtual, and why
/// [updateSubtree] lives here rather than on [Component]: the only way to
/// override it is to carry the marker, so a custom traversal can never be
/// silently skipped by the flattened pass.
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
/// any other custom traversal applied before them. Their users therefore mix
/// in [CustomTraversal] first: `with CustomTraversal, HasTimeScale`.
mixin CustomTraversal on Component {
  /// Updates this component and its subtree.
  ///
  /// The default implementation performs the engine's standard traversal:
  /// update this component, then update the children in priority order.
  void updateSubtree(double dt) => defaultUpdateSubtree(dt);
}
