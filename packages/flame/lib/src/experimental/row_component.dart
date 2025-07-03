import 'package:flame/src/experimental/layout_component.dart';
import 'package:flutter/rendering.dart';

/// RowComponent is a layout component that arranges its children in a
/// horizontal row.
///
/// The [children] are laid out along the horizontal axis, with spacing between
/// them defined by the [gap] parameter.
/// The alignment of the children along the horizontal axis is controlled by
/// [mainAxisAlignment], while their alignment along the vertical axis is
/// controlled by [crossAxisAlignment].
///
/// If [shrinkWrap] is set to true, the size of the row will shrink to fit its
/// children. Otherwise, the size of the row will be determined by the [size]
/// parameter or the size of its parent.
///
/// Example usage:
/// ```dart
/// RowComponent(
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
class RowComponent extends LayoutComponent {
  RowComponent({
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.crossAxisAlignment = CrossAxisAlignment.start,
    super.gap = 0.0,
    super.shrinkWrap = false,
    super.size,
    super.position,
    super.children,
    super.priority,
  }) : super(direction: Direction.horizontal);
}
