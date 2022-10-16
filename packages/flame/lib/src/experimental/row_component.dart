import 'package:flame/src/experimental/layout_component.dart';
import 'package:flutter/widgets.dart';

/// Allows laying out children in a row by defining a [MainAxisAlignment] type.
class RowComponent extends LayoutComponent {
  RowComponent({
    MainAxisAlignment alignment = MainAxisAlignment.start,
    double gap = 0.0,
  }) : super(
          Direction.horizontal,
          alignment,
          gap,
        );
}
