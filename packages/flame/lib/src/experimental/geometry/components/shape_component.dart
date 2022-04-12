import 'dart:ui';

import '../../../anchor.dart';
import '../../../components/component.dart';
import '../../../components/position_component.dart';
import '../../../extensions/vector2.dart';
import '../shapes/shape.dart';

/// A component that renders a simple geometric shape.
///
/// The shape is drawn using one or more [paints] provided in the constructor.
/// Several paints can be used, for example, to draw the shape with a background
/// color, a border, a shadow, etc.
class ShapeComponent extends PositionComponent {
  /// Constructs a [ShapeComponent] from the given [_shape].
  ///
  /// Furthermore, the ShapeComponent requires a list of paints for rendering,
  /// so either the parameter [paint] or [paints] must be provided (but not
  /// both).
  ///
  /// The placement of the ShapeComponent can either be specified explicitly,
  /// or it will be derived from the current location of the [_shape].
  /// Specifically, if [anchor] is not provided, it will be placed into the
  /// shape's `.center`. If [position] is not specified, then it will be derived
  /// from the shape's current location.
  ///
  /// The [_shape] passed into the constructor will be moved in such a way as to
  /// make the local coordinate system defined by the [PositionComponent]
  /// coincide with the local coordinate system of the [Shape].
  ShapeComponent(
    this._shape, {
    Paint? paint,
    List<Paint>? paints,
    Iterable<Component>? children,
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
  })  : assert(
          (paints == null) != (paint == null),
          'Either parameter `paint` or `paints` is required, but not both',
        ),
        _paints = paints ?? <Paint>[paint!],
        _path = _shape.asPath(),
        super(
          children: children,
          position: position,
          scale: scale,
          angle: angle,
          anchor: anchor,
        ) {
    final aabb = _shape.aabb;
    size = aabb.max - aabb.min;
    if (anchor == null) {
      final center = _shape.center;
      this.anchor = Anchor(
        size.x == 0 ? 0.5 : (center.x - aabb.min.x) / size.x,
        size.y == 0 ? 0.5 : (center.y - aabb.min.y) / size.y,
      );
    }
    if (position == null) {
      this.position.x = aabb.min.x + size.x * this.anchor.x;
      this.position.x = aabb.min.y + size.y * this.anchor.y;
    }
    if (!aabb.min.isZero()) {
      _shape.move(-aabb.min);
    }
  }

  final Shape _shape;
  final Path _path;

  /// The list of paints for drawing the shape.
  List<Paint> get paints => _paints;
  final List<Paint> _paints;

  @override
  void render(Canvas canvas) {
    for (final paint in _paints) {
      canvas.drawPath(_path, paint);
    }
  }

  bool containsLocalPoint(Vector2 point) => _shape.containsPoint(point);
}
