import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

/// Works similarly to flutter's Expanded widget.
/// This component must be a direct child of a [LinearLayoutComponent].
/// While this component does not do much on its own, it allows its parent
/// [LinearLayoutComponent] to alter its computations and allow it to take up
/// any free space in the main axis.
///
/// If its [parent] [LinearLayoutComponent] has [shrinkWrapMode] = true, then
///
/// ExpandedComponent never tries to shrink wrap. It only ever reports
/// [inherentSize] to its parent, and receives sizing information from its
/// parent.
///
/// However, it does need to report to its parent when its child changes size.
/// This is less important along the main-axis, and more important along the
/// cross-axis.
class ExpandedComponent extends SingleLayoutComponent
    with ParentIsA<LinearLayoutComponent> {
  ExpandedComponent({
    super.position,
    super.size,
    super.anchor,
    super.priority,
    this.inflateChild = true,
    super.child,
  });

  /// Whether or not this [ExpandedComponent] will set [child]'s size to its own
  final bool inflateChild;

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    if (child is! PositionComponent) {
      return;
    }
    // We are removing the bit about shrinkWrapMode, because this component
    // is an exception to our general shrink wrapping behavior.
    if (type == ChildrenChangeType.added) {
      child.size.addListener(layoutChildren);
    } else {
      child.size.removeListener(layoutChildren);
    }
    layoutChildren();
  }

  @override
  void layoutChildren() {
    parent.layoutChildren();
  }

  /// As of this writing, there's no clean way to both set just one component
  /// of [size], and do the same for the size of [child]. This is essential
  /// for proper layouting logic.
  /// If listeners are relied upon, the entire size gets set, even if just one
  /// component is set, resulting in listeners competing with each other.
  void setSizeComponent(int vectorIndex, double length) {
    size[vectorIndex] = length;
    final child = this.child;
    if (inflateChild && child != null) {
      // We want to set the child's size.
      // BUT it'll trigger the child size listener and trigger [layoutChildren]
      // which will trigger [parent.layoutChildren()], which will set [size],
      // resulting in an infinite loop.
      // So, we have to first remove the listener, then reattach it afterwards.
      child.size.removeListener(layoutChildren);
      child.size[vectorIndex] = length;
      child.size.addListener(layoutChildren);
    }
  }
}
