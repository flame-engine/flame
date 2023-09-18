import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/src/collisions/collision_callbacks.dart';
import 'package:flame/src/collisions/hitboxes/rectangle_hitbox.dart';
import 'package:flame/src/experimental/has_game_reference.dart';

/// This component is used to detect hitboxes colliding into the edges of the
/// viewport of the game.
class ScreenHitbox<T extends FlameGame> extends PositionComponent
    with CollisionCallbacks, HasGameReference<T> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    game.camera.viewfinder.transform.addListener(_updatePosition);
  }

  void _updatePosition() {
    final viewfinder = game.camera.viewfinder;
    position = viewfinder.position;
    anchor = viewfinder.anchor;
    angle = viewfinder.angle;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = game.camera.visibleWorldRect.size.toVector2();
  }
}
