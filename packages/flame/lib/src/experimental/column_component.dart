import 'package:flame/src/experimental/linear_layout_component.dart';
import 'package:flutter/rendering.dart';

/// ColumnComponent is a layout component that arranges its children in a
/// vertical column.
///
/// The [children] are laid out along the vertical axis, with spacing between
/// them defined by the [gap] parameter.
/// The alignment of the children along the vertical axis is controlled by
/// [mainAxisAlignment], while their alignment along the horizontal axis is
/// controlled by [crossAxisAlignment].
///
/// If [size] is non-null, behaves as normal explicit sizing.
/// If [size] is null, sets the size to the minimum size that containing all
/// the children. This is similar to setting the [size] to [inherentSize], but
/// the distinct in that sizing will respond to changes in children, other
/// properties, etc...
///
/// Example usage:
/// ```dart
/// ColumnComponent(
///   gap: 10.0,
///   mainAxisAlignment: MainAxisAlignment.center,
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: [
///     TextComponent('Child 1'),
///     TextComponent('Child 2'),
///     TextComponent('Child 3'),
///   ],
/// );
/// ```
class ColumnComponent extends LinearLayoutComponent {
  ColumnComponent({
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.crossAxisAlignment = CrossAxisAlignment.start,
    super.gap = 0.0,
    super.size,
    super.position,
    super.children,
    super.priority,
  }) : super(direction: Direction.vertical);
}
