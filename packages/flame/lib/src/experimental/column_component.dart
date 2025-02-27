import 'package:flame/src/experimental/layout_component.dart';
import 'package:flutter/rendering.dart';

/// Arranges [children] in a column, [gap] points apart.
/// The [children] are arranged [mainAxisAlignment] along the vertical axis,
/// and [crossAxisAlignment] along the horizontal axis.
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
