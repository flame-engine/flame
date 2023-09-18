import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Keeps track of all the [ShapeHitbox]s in the component's tree and initiates
/// collision detection every tick.
///
/// Hitboxes are only part of the collision detection performed by its closest
/// parent with the [HasCollisionDetection] mixin, if there are multiple nested
/// classes that has [HasCollisionDetection].
///
/// You can experiment with non-standard collision detection methods, such
/// as `HasQuadTreeCollisionDetection`. This can sometimes bring better
/// performance, but it's not guaranteed.
mixin HasCollisionDetection<B extends Broadphase<ShapeHitbox>> on Component {
  CollisionDetection<ShapeHitbox, B> _collisionDetection =
      StandardCollisionDetection();
  CollisionDetection<ShapeHitbox, B> get collisionDetection =>
      _collisionDetection;

  set collisionDetection(CollisionDetection<ShapeHitbox, B> cd) {
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
mixin HasGenericCollisionDetection<T extends Hitbox<T>, B extends Broadphase<T>>
    on Component {
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
