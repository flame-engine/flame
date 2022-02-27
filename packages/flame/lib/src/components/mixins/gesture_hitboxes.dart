import 'package:meta/meta.dart';

import '../../../collisions.dart';
import '../../../components.dart';

/// This mixin can be used if you want to use hitboxes to determine whether
/// a gesture is within the [Component] or not.
mixin GestureHitboxes on Component {
  Iterable<HitboxShape> get hitboxes => children.query<HitboxShape>();

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    super.onLoad();
    children.register<HitboxShape>();
  }

  @override
  bool containsPoint(Vector2 point) {
    return hitboxes.any((hitbox) => hitbox.containsPoint(point));
  }
}
