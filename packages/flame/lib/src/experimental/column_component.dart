import 'package:flame/src/experimental/layout_component.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

/// Allows laying out children in a column by defining a [MainAxisAlignment]
/// type.
class ColumnComponent extends LayoutComponent {
  ColumnComponent({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    double gap = 0.0,
    Vector2? size,
  }) : super(
          Direction.vertical,
          mainAxisAlignment,
          gap,
          size,
        );
}
