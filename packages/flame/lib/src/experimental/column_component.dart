import 'package:flame/src/experimental/layout_component.dart';
import 'package:flutter/rendering.dart';

class ColumnComponent extends LayoutComponent {
  ColumnComponent({
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.crossAxisAlignment = CrossAxisAlignment.start,
    super.gap = 0.0,
    super.size,
    super.position,
    super.children,
  }) : super(direction: Direction.vertical);
}
