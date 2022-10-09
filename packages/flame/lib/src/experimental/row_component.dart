import 'package:flame/src/experimental/layout_component.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

/// Allows laying out children in a row by defining a [MainAxisAlignment] type.
class RowComponent extends LayoutComponent {
  RowComponent({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    double gap = 0.0,
    Vector2? size,
  }) : super(
          Direction.horizontal,
          mainAxisAlignment,
          gap,
          size,
        );
}
