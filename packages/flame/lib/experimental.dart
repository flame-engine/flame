/// Classes and components in this sub-module are considered experimental,
/// that is, their API may still be incomplete and subject to change at a more
/// rapid pace than the rest of the Flame code.
///
/// However, do not feel discouraged to use this functionality: on the contrary,
/// consider this as a way to help the Flame community by beta-testing new
/// components.
///
/// After the components lived here for some time, and when we gain more
/// confidence in their robustness, they will be moved out into the main Flame
/// library.
library experimental;

export 'src/experimental/column_component.dart' show ColumnComponent;
export 'src/experimental/geometry/shapes/circle.dart' show Circle;
export 'src/experimental/geometry/shapes/polygon.dart' show Polygon;
export 'src/experimental/geometry/shapes/rectangle.dart' show Rectangle;
export 'src/experimental/geometry/shapes/rounded_rectangle.dart'
    show RoundedRectangle;
export 'src/experimental/geometry/shapes/shape.dart' show Shape;
export 'src/experimental/layout_component.dart' show LayoutComponent;
export 'src/experimental/linear_layout_component.dart'
    show LinearLayoutComponent, Direction;
export 'src/experimental/padding_component.dart' show PaddingComponent;
export 'src/experimental/row_component.dart' show RowComponent;
