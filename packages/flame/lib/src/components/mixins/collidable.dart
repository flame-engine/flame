import '../../../components.dart';
import '../../../game.dart';
import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';
import 'hitbox.dart';

/// [CollidableType.active] collides with other [Collidable]s of type active or static
/// [CollidableType.passive] collides with other [Collidable]s of type active
/// [CollidableType.inactive] will not collide with any other [Collidable]s
enum CollidableType {
  active,
  passive,
  inactive,
}

mixin Collidable on Hitbox {
  CollidableType collidableType = CollidableType.active;

  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}
  void onCollisionEnd(Collidable other) {}
}

class ScreenCollidable extends PositionComponent
    with Hitbox, Collidable, HasGameRef<BaseGame> {
  @override
  CollidableType collidableType = CollidableType.passive;

  final Vector2 _effectiveSize = Vector2.zero();
  double _zoom = 1.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateSize();
    addShape(HitboxRectangle());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateSize();
  }

  void _updateSize() {
    if (_effectiveSize != gameRef.viewport.effectiveSize ||
        _zoom != gameRef.camera.zoom) {
      _effectiveSize.setFrom(gameRef.viewport.effectiveSize);
      _zoom = gameRef.camera.zoom;
      size = _effectiveSize / _zoom;
    }
  }
}
