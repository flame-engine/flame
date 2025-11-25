import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/rendering.dart';

/// A padding component akin to Flutter's Padding widget.
/// Use [padding] as you would Flutter's counterpart.
/// While this component is designed to shrink or expand to its child's
/// dimensions, it is fine to set its size explicitly. The child will simply be
/// offset by the padding dimensions.
///
/// Set the child of this component with [child]. Avoid using [add] directly on
/// an instance of [PaddingComponent] because its behavior is undefined with
/// multiple children. It is designed only for one child.
///
/// You may set [padding] as well as the [child] after the fact, and it will
/// cause the layout to refresh.
///
/// Example usage:
/// ```dart
/// PaddingComponent(
///   padding: EdgeInsets.all(10),
///   child: TextComponent(text: 'bar')
/// );
/// ```
class PaddingComponent extends SingleLayoutComponent {
  PaddingComponent({
    super.key,
    EdgeInsets? padding,
    super.anchor,
    super.position,
    super.priority,
    super.size,
    PositionComponent? child,
  }) : _padding = padding ?? EdgeInsets.zero,
       super(child: null) {
    this.child = child;
  }

  EdgeInsets _padding;

  EdgeInsets get padding => _padding;

  set padding(EdgeInsets value) {
    _padding = value;
    layoutChildren();
  }

  @override
  void layoutChildren() {
    // Only resets to null if it's already null. This way, we avoid overwriting
    // an explicit width/height.
    resetSize();
    final child = this.child;
    if (child == null) {
      return;
    }
    // Regardless of shrinkwrap or size, top left padding is set.
    child.topLeftPosition.setFrom(padding.topLeft.toVector2());
  }

  @override
  Vector2 get intrinsicSize {
    final childWidth = child?.size.x ?? 0;
    final childHeight = child?.size.y ?? 0;
    return Vector2(
      childWidth + padding.horizontal,
      childHeight + padding.vertical,
    );
  }
}
