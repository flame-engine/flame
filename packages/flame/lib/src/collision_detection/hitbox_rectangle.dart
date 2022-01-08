import '../../components.dart';
import '../../geometry.dart';
import 'hitbox_shape.dart';

class HitboxRectangle extends Rectangle with HasHitboxes, HitboxShape {
  HitboxRectangle({
    Vector2? position,
    Vector2? size,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          position: position,
          size: size,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    shouldFillParent = position == null && size == null;
  }

  @override
  void fillParent() {
    // No need to do anything since the size already is bound to the parent size
  }
}
