import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

/// Works similarly to flutter's Expanded widget.
/// This component must be a direct child of a [LinearLayoutComponent].
/// While this component does not do much on its own, it allows its parent
/// [LinearLayoutComponent] to alter its computations and allow it to take up
/// any free space in the main axis.
///
/// If its [parent] [LinearLayoutComponent] shrink-wraps in the main axis, then
/// this component isn't expanded.
///
/// ExpandedComponent never tries to shrink-wrap. It only ever reports
/// [intrinsicSize] to its parent, and receives sizing information from its
/// parent.
///
/// However, it does need to report to its parent when its child changes size.
/// This is less important along the main-axis, and more important along the
/// cross-axis.
class ExpandedComponent extends SingleLayoutComponent
    with ParentIsA<LinearLayoutComponent> {
  ExpandedComponent({
    super.key,
    super.position,
    super.anchor,
    super.priority,
    this.inflateChild = true,
    super.child,
  }) : super(size: null);

  /// Whether or not this [ExpandedComponent] will set [child]'s size to its own
  final bool inflateChild;

  @override
  void setLayoutAxisLength(int axisIndex, double? value) {
    super.setLayoutAxisLength(axisIndex, value);
    final child = this.child;
    if (inflateChild && child != null && value != null) {
      // We want to set the child's size.
      if (child is LayoutComponent) {
        child.setLayoutAxisLength(axisIndex, value);
      } else {
        child.size[axisIndex] = value;
      }
    }
  }

  @override
  void layoutChildren() {
    resetSize();
    parent.layoutChildren();
  }
}
