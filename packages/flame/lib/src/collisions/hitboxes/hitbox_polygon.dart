import '../../../collisions.dart';
import '../../../components.dart';
import '../../../geometry.dart';

/// A [Hitbox] in the shape of a polygon.
class HitboxPolygon extends PolygonComponent with HitboxShape {
  HitboxPolygon(
    List<Vector2> vertices, {
    double? angle,
    Anchor? anchor,
  }) : super(
          vertices,
          angle: angle,
          anchor: anchor,
        );

  /// With this constructor you define the [HitboxPolygon] in relation to the
  /// [size] of the hitbox.
  ///
  /// Example: `[[1.0, 0.0], [0.0, -1.0], [-1.0, 0.0], [0.0, 1.0]]`
  /// This will form a diamond shape within the bounding size box.
  /// NOTE: Always define your shape in a counter-clockwise fashion (in the
  /// screen coordinate system)
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
