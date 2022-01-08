import '../../components.dart';
import '../../geometry.dart';
import 'hitbox_shape.dart';

class HitboxPolygon extends Polygon with HasHitboxes, HitboxShape {
  factory HitboxPolygon({
    required List<Vector2> vertices,
    double angle = 0,
  }) {
    return Polygon(
      vertices,
      angle: angle,
    ) as HitboxPolygon;
  }

  @override
  void fillParent() {
    throw UnsupportedError(
      'Use the HitboxRectangle if you want to fill the parent',
    );
  }
}
