import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Keeps track of all the [ShapeHitbox]s in the component tree and initiates
/// collision detection every tick.
mixin HasCollisionDetection<B extends Broadphase<ShapeHitbox>> on FlameGame {
  CollisionDetection<ShapeHitbox, B> _collisionDetection =
      StandardCollisionDetection(
    broadphase: Sweep<ShapeHitbox>(broadphaseCheck: _onComponentTypeCheck) as B,
  );

  CollisionDetection<ShapeHitbox, B> get collisionDetection =>
      _collisionDetection;

  set collisionDetection(CollisionDetection<ShapeHitbox, B> cd) {
    cd.addAll(_collisionDetection.items);
    _collisionDetection = cd;
  }

  bool onComponentTypeCheck(PositionComponent one, PositionComponent another) =>
      _onComponentTypeCheck(one, another);

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}

bool _onComponentTypeCheck(PositionComponent one, PositionComponent another) {
  var checkParent = false;
  if (one is GenericCollisionCallbacks) {
    if (!(one as GenericCollisionCallbacks).onComponentTypeCheck(another)) {
      return false;
    }
  } else {
    checkParent = true;
  }

  if (another is GenericCollisionCallbacks) {
    if (!(another as GenericCollisionCallbacks).onComponentTypeCheck(one)) {
      return false;
    }
  } else {
    checkParent = true;
  }

  if (checkParent && one is ShapeHitbox && another is ShapeHitbox) {
    return _onComponentTypeCheck(one.hitboxParent, another.hitboxParent);
  }
  return true;
}

/// This mixin is useful if you have written your own collision detection which
/// isn't operating on [ShapeHitbox] since you can have any hitbox here.
///
/// Do note that [collisionDetection] has to be initialized before the game
/// starts the update loop for the collision detection to work.
mixin HasGenericCollisionDetection<T extends Hitbox<T>, B extends Broadphase<T>>
    on FlameGame {
  CollisionDetection<T, B>? _collisionDetection;

  CollisionDetection<T, B> get collisionDetection => _collisionDetection!;

  set collisionDetection(CollisionDetection<T, B> cd) {
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
