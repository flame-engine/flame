import '../../components.dart';
import '../../geometry.dart';
import 'hitbox_shape.dart';

class HitboxPolygon extends Polygon with HasHitboxes, HitboxShape {
  HitboxPolygon(
    List<Vector2> vertices, {
    double? angle,
    Anchor? anchor,
  }) : super(
          vertices,
          angle: angle,
          anchor: anchor,
        );

  HitboxPolygon.fromNormals(
    List<Vector2> normals, {
    Vector2? position,
    required Vector2 size,
    double angle = 0,
    Anchor? anchor,
  }) : super.fromNormals(
          normals,
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
        );

  @override
  void fillParent() {
    throw UnsupportedError(
      'Use the HitboxRectangle if you want to fill the parent',
    );
  }
}
