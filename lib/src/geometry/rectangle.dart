import 'dart:ui';

import '../../components.dart';
import '../../extensions.dart';
import 'shape.dart';

class Rectangle extends Polygon {
  /// The [relation] describes the relationship between x any y in the
  /// rectangle, not the size of the rectangle, both x and y in the [Vector2]
  /// should therefore be less or equal to 1.0.
  /// If you want to create the [Rectangle] from a positioned [Rect] instead,
  /// have a look at [Rectangle.toRect].
  Rectangle(
    Vector2 relation, {
    Vector2 position,
    Vector2 size,
    double angle,
  }) : super([
          relation.clone(),
          Vector2(relation.x, -relation.y),
          -relation,
          Vector2(-relation.x, relation.y),
        ], position: position, size: size, angle: angle = 0);

  /// With this helper method you can create your [Rectangle] from a positioned
  /// [Rect] instead of percentages. This helper will also calculate the size
  /// and center of the [Rectangle].
  factory Rectangle.fromRect(
    Rect rect, {
    double angle = 0,
  }) {
    return Rectangle(
      rect.size.toVector2() / 2,
      position: rect.center.toVector2(),
      angle: angle,
    );
  }

  //@override
  //void render(Canvas canvas, Paint paint) {
  //  canvas.drawRect(definition[3].toPositionedRect(topLeftPosition), paint);
  //}
}

class HitboxRectangle extends Rectangle with HitboxShape {
  HitboxRectangle(Vector2 relation) : super(relation);
}
