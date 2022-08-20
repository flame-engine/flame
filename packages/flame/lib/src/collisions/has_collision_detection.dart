import 'package:flame/collisions.dart';
import 'package:flame/game.dart';

/// Keeps track of all the [ShapeHitbox]s in the component tree and initiates
/// collision detection every tick.
mixin HasCollisionDetection on FlameGame {
  CollisionDetection<ShapeHitbox> _collisionDetection =
      StandardCollisionDetection();
  CollisionDetection<ShapeHitbox> get collisionDetection => _collisionDetection;

  set collisionDetection(CollisionDetection<ShapeHitbox> cd) {
    cd.addAll(_collisionDetection.items);
    _collisionDetection = cd;
  }

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}

/// This mixin is useful if you have written your own collision detection which
/// isn't operating on [ShapeHitbox] since you can have any hitbox here.
///
/// Do note that [collisionDetection] has to be initialized before the game
/// starts the update loop for the collision detection to work.
mixin HasGenericCollisionDetection<T extends Hitbox<T>> on FlameGame {
  CollisionDetection<T>? _collisionDetection;
  CollisionDetection<T> get collisionDetection => _collisionDetection!;

  set collisionDetection(CollisionDetection<T> cd) {
    if (_collisionDetection != null) {
      cd.addAll(_collisionDetection!.items);
    }
    _collisionDetection = cd;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _collisionDetection?.run();
  }
}
