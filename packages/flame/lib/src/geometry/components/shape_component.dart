import 'dart:ui';

import '../../anchor.dart';
import '../../components/component.dart';
import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../shapes/shape.dart';

class ShapeComponent extends PositionComponent {
  ShapeComponent(
    this.shape, {
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
        paints = paints ?? [paint!],
        _path = shape.asPath(),
        super(
          children: children,
          position: position,
          scale: scale,
          angle: angle,
          anchor: anchor,
        ) {
    final aabb = shape.aabb;
    if (!aabb.min.isZero()) {
      shape.move(-aabb.min);
      this.position.add(aabb.min);
    }
    size = aabb.max - aabb.min;
    if (anchor == null) {
      final center = shape.center;
      this.anchor = Anchor(
          size.x == 0? 0.5 : center.x/size.x,
          size.y == 0? 0.5 : center.y/size.y,
      );
    }
  }

  final Shape shape;
  final List<Paint> paints;
  final Path _path;

  @override
  void render(Canvas canvas) {
    for (final paint in paints) {
      canvas.drawPath(_path, paint);
    }
  }
}
