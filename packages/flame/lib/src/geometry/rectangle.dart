import '../../components.dart';
import '../../extensions.dart';
import '../../geometry.dart';

class Rectangle extends Polygon {
  static final _defaultNormalizedVertices = [
    Vector2(1, 1),
    Vector2(1, -1),
    Vector2(-1, -1),
    Vector2(-1, 1),
  ];

  Rectangle({
    Vector2? position,
    Vector2? size,
    double angle = 0,
  }) : super.fromDefinition(
          _defaultNormalizedVertices,
          position: position,
          size: size,
          angle: angle,
        );

  /// This constructor is used by [HitboxRectangle] and is most often not useful
  /// for any other cases.
  /// The [relation] describes the relationship between x and y and the size of
  /// the rectangle, both x and y in [relation] should be less or equal to 1.0
  /// if this should be used for collision detection.
  ///
  /// For example if the [size] is (100, 100) and the [relation] is (0.5, 1.0)
  /// the it will represent a rectangle with the points (25, 50), (25, -50),
  /// (-25, -50) and (-25, 50) because the rectangle is defined from the center
  /// of itself. The [position] will therefore be the center of the Rectangle.
  ///
  /// If you want to create the [Rectangle] from a positioned [Rect] instead,
  /// have a look at [Rectangle.fromRect].
  Rectangle.fromDefinition({
    Vector2? relation,
    Vector2? position,
    Vector2? size,
    double angle = 0,
  }) : super.fromDefinition(
          relation != null
              ? [
                  relation.clone(),
                  Vector2(relation.x, -relation.y),
                  -relation,
                  Vector2(-relation.x, relation.y),
                ]
              : _defaultNormalizedVertices,
          position: position,
          size: size,
          angle: angle,
        );

  /// With this helper method you can create your [Rectangle] from a positioned
  /// [Rect] instead of percentages. This helper will also calculate the size
  /// and center of the [Rectangle].
  factory Rectangle.fromRect(
    Rect rect, {
    double angle = 0,
  }) {
    return Rectangle.fromDefinition(
      position: rect.center.toVector2(),
      size: rect.size.toVector2(),
      angle: angle,
    );
  }
}

class HitboxRectangle extends Rectangle with HasHitboxes, HitboxShape {
  HitboxRectangle({Vector2? relation})
      : super.fromDefinition(
          relation: relation ?? Vector2.all(1),
        );
}
