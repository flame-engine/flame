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
    int? priority,
  })  : shouldFillParent = radius == null && position == null,
        super(
          radius: radius,
          position: position,
          angle: angle,
          priority: priority,
        );

  @override
  void fillParent() {
    // No need to do anything since the size already is bound to the parent size
  }
}
