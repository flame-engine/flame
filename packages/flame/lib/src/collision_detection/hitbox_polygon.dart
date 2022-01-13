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

  // TODO(spydon): Change name
  factory HitboxPolygon.fromNormal({
  required List<Vector2> normals,
    required Vector2 size,
    Anchor anchor = Anchor.center,
  double angle = 0,
  }) {
    final position = anchor.
    return Polygon(
      normals.map((v) => v.clone()..multiply(),
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
