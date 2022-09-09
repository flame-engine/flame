import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

/// Mixin should be applied to FlameGame to bring QuadTree collision support.
/// [initCollisionDetection] should be called at [onLoad] function.
///
mixin HasQuadTreeCollisionDetection on FlameGame
    implements HasCollisionDetection {
  late CollisionDetection<ShapeHitbox> _collisionDetection;

  @override
  CollisionDetection<ShapeHitbox> get collisionDetection => _collisionDetection;

  @override
  set collisionDetection(CollisionDetection<Hitbox> cd) {
    if (cd is! QuadTreeCollisionDetection) {
      throw 'Must be QuadTreeCollisionDetection!';
    }
    _collisionDetection = cd;
  }

  /// Initialise QuadTree with params:
  /// - [mapDimensions] describes collision area coordinates and size. Should
  ///   match to game map position and size
  /// - [maxObjects] (optional) - maximum objects count in one quadrant
  /// - [maxLevels] (optional) - maximum nested quadrants
  /// - [minimumDistance] (optional) - specify minimum distance between objects
  ///   to consider them as possibly collideable. You also can reimplement
  ///   [minimumDistanceCheck] if you need some custom behavior
  ///
  /// [broadPhaseCheck] checks if objects of different types should to collide.
  /// The result of calculation is cached so you should not check here any
  /// dynamical parameters, the function intended to be used as pure type
  /// checker.
  /// It usually should not be reimplemented, see
  /// [HasQuadTreeController.broadPhaseCheck] instead
  ///
  void initCollisionDetection({
    required Rect mapDimensions,
    double? minimumDistance,
    int maxObjects = 25,
    int maxLevels = 10,
  }) {
    _collisionDetection = QuadTreeCollisionDetection(
      mapDimensions: mapDimensions,
      maxLevels: maxLevels,
      maxObjects: maxObjects,
      broadphaseCheck: broadPhaseCheck,
      minimumDistanceCheck: minimumDistanceCheck,
    );
    this.minimumDistance = minimumDistance;
  }

  double? minimumDistance;

  bool minimumDistanceCheck(Vector2 activeItemCenter, Vector2 potentialCenter) {
    if (minimumDistance != null) {
      if ((activeItemCenter.x - potentialCenter.x).abs() > minimumDistance! ||
          (activeItemCenter.y - potentialCenter.y).abs() > minimumDistance!) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  bool broadPhaseCheck(PositionComponent one, PositionComponent another) {
    var checkParent = false;
    if (one is HasQuadTreeController) {
      if (!one.broadPhaseCheck(another)) {
        return false;
      }
    } else {
      checkParent = true;
    }

    if (another is HasQuadTreeController) {
      if (!another.broadPhaseCheck(one)) {
        return false;
      }
    } else {
      checkParent = true;
    }
    final oneParent = one.parent;
    final anotherParent = another.parent;

    if (checkParent &&
        oneParent is HasQuadTreeController &&
        anotherParent is HasQuadTreeController) {
      return broadPhaseCheck(oneParent, anotherParent);
    }
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    collisionDetection.run();
  }
}
