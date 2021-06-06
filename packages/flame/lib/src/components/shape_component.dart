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
    this.shapePaint, {
    Anchor anchor = Anchor.center,
    int? priority,
  }) : super(
          position: shape.position,
          size: shape.size,
          angle: shape.angle,
          anchor: anchor,
          priority: priority,
        ) {
    shape.isCanvasPrepared = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    shape.render(canvas, shapePaint);
  }

  @override
  bool containsPoint(Vector2 point) => shape.containsPoint(point);
}
