import 'package:flame/src/experimental/layout_component.dart';
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
/// If [shrinkWrap] is set to true, the size of the column will shrink its size
/// fit its children. Otherwise, the size of the column will be determined by
/// the [size] parameter or the size of its parent.
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
class ColumnComponent extends LayoutComponent {
  ColumnComponent({
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.crossAxisAlignment = CrossAxisAlignment.start,
    super.gap = 0.0,
    super.shrinkWrap = false,
    super.size,
    super.position,
    super.children,
  }) : super(direction: Direction.vertical);
}
