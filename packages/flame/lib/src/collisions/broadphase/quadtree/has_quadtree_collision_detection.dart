import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

/// This should be applied to a [FlameGame] to bring QuadTree collision
/// support.
///
/// [initializeCollisionDetection] should be called in the game's [onLoad]
/// method.
mixin HasQuadTreeCollisionDetection on FlameGame
    implements HasCollisionDetection<QuadTreeBroadphase<ShapeHitbox>> {
  late QuadTreeCollisionDetection _collisionDetection;

  @override
  QuadTreeCollisionDetection get collisionDetection => _collisionDetection;

  @override
  set collisionDetection(
    CollisionDetection<ShapeHitbox, QuadTreeBroadphase<ShapeHitbox>> cd,
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

  bool onComponentTypeCheck(PositionComponent one, PositionComponent another) {
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
      return onComponentTypeCheck(one.hitboxParent, another.hitboxParent);
    }
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}
