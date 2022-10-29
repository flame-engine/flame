import 'package:flame/src/experimental/layout_component.dart';

/// Allows laying out children in a column by defining a
/// [LayoutComponentAlignment] type.
class ColumnComponent extends LayoutComponent {
  ColumnComponent({
    LayoutComponentAlignment alignment = LayoutComponentAlignment.start,
    double gap = 0.0,
  }) : super(
          Direction.vertical,
          alignment,
          gap,
        );
}
