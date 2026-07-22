import 'package:flame/src/components/core/component.dart';

/// The marker mixin for components that manage the update traversal of their
/// own subtree, instead of the engine's standard "update self, then update
/// every child in priority order" recursion.
///
/// Mix this in (and override [Component.updateSubtree]) to customize the
/// traversal. The mixin is both the capability and the barrier marker: the
/// engine's flattened update pass treats every [CustomTraversal] component
/// as a barrier, calls its [Component.updateSubtree], and lets that method
/// drive the subtree. This is also why [Component.updateTree] is
/// non-virtual: an updateTree override without a marker would be silently
/// skipped by the flattened traversal.
///
/// ```dart
/// class SlowMotionArea extends Component with CustomTraversal {
///   @override
///   void updateSubtree(double dt) => super.updateSubtree(dt / 2);
/// }
/// ```
///
/// Mixins that provide a custom traversal (like `HasTimeScale`) should be
/// declared `on Component implements CustomTraversal`: the `implements`
/// carries the marker, so that their users do not need to add
/// [CustomTraversal] themselves, and `super.updateSubtree` chains through
/// any other custom traversal in the mixin application order.
mixin CustomTraversal on Component {}
