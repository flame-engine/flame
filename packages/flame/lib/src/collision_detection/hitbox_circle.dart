import '../../components.dart';
import '../../geometry.dart';
import 'hitbox_shape.dart';

class HitboxCircle extends Circle with HasHitboxes, HitboxShape {
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

  @override
  void fillParent() {
    // There is no need to do anything here since the size already is bound to
    // the parent size and the radius is defined from the shortest side.
  }
}
