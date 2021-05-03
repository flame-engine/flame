import 'dart:ui' hide Offset;

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

import '../anchor.dart';
import '../extensions/offset.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import '../geometry/rectangle.dart';
import 'base_component.dart';
import 'component.dart';
import 'mixins/hitbox.dart';

class ShapeComponent extends PositionComponent {
  final Shape shape;
  final Paint shapePaint;

  ShapeComponent(this.shape, this.shapePaint,
  )  : super(position: shape.position, size: shape.size, angle: shape.angle, anchor: Anchor.center,);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    shape.render(canvas, shapePaint);
  }
  
  @override
  bool containsPoint(Vector2 point) => shape.containsPoint(point);
}
