import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';

/// A padding component akin to Flutter's Padding widget.
/// Use [padding] as you would Flutter's counterpart.
/// In general, do not set the size of this widget explicitly, because it is
/// only designed to shrink or expand to its child's dimensions, plus padding.
///
/// Set the child of this component with [child]. Avoid using [add] directly on
/// an instance of [PaddingComponent] because its behavior is undefined with
/// multiple children. It is designed only for one child.
///
/// You may set [padding] as well as the [child] after the fact, and it will
/// cause the layout to refresh.
class PaddingComponent extends SingleLayoutComponent {
  PaddingComponent({
    EdgeInsets? padding,
    super.anchor,
    super.position,
    super.priority,
    super.child,
    super.size,
  }) : _padding = padding ?? EdgeInsets.zero;
  EdgeInsets _padding;

  EdgeInsets get padding => _padding;

  set padding(EdgeInsets value) {
    _padding = value;
    layoutChildren();
  }

  @override
  void layoutChildren() {
    super.layoutChildren();
    final child = this.child;
    if (child == null) {
      return;
    }
    // Regardless of shrinkwrap or size, top left padding is set.
    child.topLeftPosition.setFrom(padding.topLeft.toVector2());
  }

  @override
  Vector2 get inherentSize {
    final childWidth = child?.size.x ?? 0;
    final childHeight = child?.size.y ?? 0;
    return Vector2(
      childWidth + padding.horizontal,
      childHeight + padding.vertical,
    );
  }
}
