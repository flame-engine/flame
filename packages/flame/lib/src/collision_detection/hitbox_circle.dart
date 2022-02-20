import '../../collision_detection.dart';
import '../../components.dart';
import '../../geometry.dart';

class HitboxCircle extends Circle with HitboxShape {
  @override
  final bool shouldFillParent;

  HitboxCircle({
    double? radius,
    Vector2? position,
    double? angle,
    Anchor? anchor,
  })  : shouldFillParent = radius == null && position == null,
        super(
          radius: radius,
          position: position,
          angle: angle,
          anchor: anchor,
        );

  HitboxCircle.fromNormal(
    double normal, {
    Vector2? position,
    required Vector2 size,
    double angle = 0,
    Anchor? anchor,
  })  : shouldFillParent = false,
        super.fromNormal(
          normal,
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
        );

  @override
  void fillParent() {
    // There is no need to do anything here since the size already is bound to
    // the parent size and the radius is defined from the shortest side.
  }
}
