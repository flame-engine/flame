import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// This mixin can be used if you want to use hitboxes to determine whether
/// a gesture is within the [Component] or not.
mixin GestureHitboxes on Component {
  Iterable<ShapeHitbox> get hitboxes => children.query<ShapeHitbox>();

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    super.onLoad();
    children.register<ShapeHitbox>();
  }

  @override
  bool containsPoint(Vector2 point) {
    return hitboxes.any((hitbox) => hitbox.containsPoint(point));
  }
}
