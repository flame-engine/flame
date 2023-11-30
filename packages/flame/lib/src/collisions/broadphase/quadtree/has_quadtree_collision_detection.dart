import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

/// This should be applied to a [FlameGame] to bring QuadTree collision
/// support.
///
/// Use [HasQuadTreeCollisionDetection] if you have lots of collidable entities
/// in your game, but most of them are static (such as platforms, walls, trees,
/// buildings).
///
/// Always experiment before deciding which collision detection
/// method to use. It's not unheard of to see better performance with
/// the default [HasCollisionDetection] mixin.
///
/// [initializeCollisionDetection] should be called in the game's [onLoad]
/// method.
mixin HasQuadTreeCollisionDetection<W extends World> on FlameGame<W>
    implements HasCollisionDetection<QuadTreeBroadphase> {
  late QuadTreeCollisionDetection _collisionDetection;

  @override
  QuadTreeCollisionDetection get collisionDetection => _collisionDetection;

  @override
  set collisionDetection(
    CollisionDetection<ShapeHitbox, QuadTreeBroadphase> cd,
  ) {
    if (cd is! QuadTreeCollisionDetection) {
      throw 'Must be QuadTreeCollisionDetection!';
    }
    _collisionDetection = cd;
  }

  /// Initialize the QuadTree.
  ///
  /// - [mapDimensions] describes the collision area coordinates and size.
  ///   Should match to game map's position and size.
  /// - [maxObjects] (optional) - maximum amount of objects in one quadrant.
  /// - [maxLevels] (optional) - maximum number of nested quadrants.
  /// - [minimumDistance] (optional) - specify minimum distance between objects
  ///   to consider them as possibly colliding. You can also implement the
  ///   [minimumDistanceCheck] if you need some custom behavior.
  ///
  /// The [onComponentTypeCheck] checks if objects of different types should
  /// collide.
  /// The result of the calculation is cached so you should not check any
  /// dynamical parameters here, the function is intended to be used as pure
  /// type checker.
  /// It should usually not be overridden, see
  /// [CollisionCallbacks.onComponentTypeCheck] instead
  void initializeCollisionDetection({
    required Rect mapDimensions,
    double? minimumDistance,
    int maxObjects = 25,
    int maxLevels = 10,
  }) {
    _collisionDetection = QuadTreeCollisionDetection(
      mapDimensions: mapDimensions,
      maxDepth: maxLevels,
      maxObjects: maxObjects,
      onComponentTypeCheck: onComponentTypeCheck,
      minimumDistanceCheck: minimumDistanceCheck,
    );
    this.minimumDistance = minimumDistance;
  }

  double? minimumDistance;

  bool minimumDistanceCheck(Vector2 activeItemCenter, Vector2 potentialCenter) {
    return minimumDistance == null ||
        !((activeItemCenter.x - potentialCenter.x).abs() > minimumDistance! ||
            (activeItemCenter.y - potentialCenter.y).abs() > minimumDistance!);
  }

  bool onComponentTypeCheck(ShapeHitbox first, ShapeHitbox second) {
    return first.onComponentTypeCheck(second) &&
        second.onComponentTypeCheck(first);
  }

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}
