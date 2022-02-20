import '../../collision_detection.dart';
import '../../components.dart';
import '../../geometry.dart';

class HitboxRectangle extends RectangleComponent with HitboxShape {
  @override
  final bool shouldFillParent;

  HitboxRectangle({
    Vector2? position,
    Vector2? size,
    double? angle,
    Anchor? anchor,
    int? priority,
  })  : shouldFillParent = size == null && position == null,
        super(
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  /// With this constructor you define the [HitboxRectangle] in relation to
  /// the [size]. For example having [normal] as of (0.8, 0.5) would create a
  /// rectangle that fills 80% of the width and 50% of the height of [size].
  HitboxRectangle.fromNormals(
    Vector2 normal, {
    Vector2? position,
    required Vector2 size,
    double angle = 0,
    Anchor? anchor,
  })  : shouldFillParent = false,
        super.fromNormals(
          normal,
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
        );

  @override
  void fillParent() {
    refreshVertices(
      newVertices: RectangleComponent.sizeToVertices(size, anchor),
    );
  }
}
