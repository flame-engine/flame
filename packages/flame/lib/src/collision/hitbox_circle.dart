import '../../components.dart';
import '../../geometry.dart';

class HitboxCircle extends Circle with HasHitboxes, HitboxShape {
  HitboxCircle({
    double? radius,
    Vector2? position,
    double? angle,
    int? priority,
  }) : super(
          radius: radius,
          position: position,
          angle: angle,
          priority: priority,
        );
}
