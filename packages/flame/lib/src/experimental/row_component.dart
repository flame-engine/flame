import 'package:flame/src/experimental/layout_component.dart';
import 'package:flutter/rendering.dart';

/// Arranges [children] in a row, [gap] points apart.
/// The [children] are arranged [mainAxisAlignment] along the horizontal axis,
/// and [crossAxisAlignment] along the vertical axis.
class RowComponent extends LayoutComponent {
  RowComponent({
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.crossAxisAlignment = CrossAxisAlignment.start,
    super.gap = 0.0,
    super.shrinkWrap = false,
    super.size,
    super.position,
    super.children,
  }) : super(direction: Direction.horizontal);
}
