import 'package:flame/src/experimental/layout_component.dart';
import 'package:flutter/widgets.dart';

/// Allows laying out children in a column by defining a [MainAxisAlignment]
/// type.
class ColumnComponent extends LayoutComponent {
  ColumnComponent({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    double gap = 0.0,
  }) : super(Direction.vertical, mainAxisAlignment, gap);
}
