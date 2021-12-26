import '../../components.dart';
import '../../extensions.dart';
import '../../geometry.dart';
import '../geometry/shape_intersections.dart' as intersection_system;

mixin HitboxShape on Shape implements HasHitboxes {
  @override
  void render(_) {}

  @override
  void renderDebugMode(Canvas c) {
    super.render(c);
  }

  /// Checks whether the [HitboxShape] contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    return possiblyContainsPoint(point) && super.containsPoint(point);
  }

  /// Where this [Shape] has intersection points with another shape
  @override
  Set<Vector2> intersections(HasHitboxes other) {
    assert(
      other is Shape,
      'The intersection can only be performed between shapes',
    );
    return intersection_system.intersections(this, other as Shape);
  }
}
