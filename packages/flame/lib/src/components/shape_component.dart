import 'dart:ui' hide Offset;

import '../../components.dart';
import '../../geometry.dart';
import '../anchor.dart';
import '../extensions/vector2.dart';

class ShapeComponent extends PositionComponent {
  final Shape shape;
  final Paint shapePaint;

  ShapeComponent(
    this.shape,
    this.shapePaint,
  ) : super(
          position: shape.position,
          size: shape.size,
          angle: shape.angle,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    shape.render(canvas, shapePaint);
  }

  @override
  bool containsPoint(Vector2 point) => shape.containsPoint(point);
}
