import 'dart:ui';

import '../../components.dart';
import '../components/cache/value_cache.dart';
import 'shape_intersections.dart' as intersection_system;

/// A shape can represent any geometrical shape with optionally a size, position
/// and angle. It can also have an anchor if it shouldn't be rotated around its
/// center.
/// A point can be determined to be within of outside of a shape.
abstract class Shape {
  final ValueCache<Vector2> _halfSizeCache = ValueCache();
  final ValueCache<Vector2> _localCenterCache = ValueCache();
  final ValueCache<Vector2> _absoluteCenterCache = ValueCache();
  final ValueCache<Vector2> _relativePositionCache = ValueCache();

  // These are used to avoid creating new vector objects on some method calls
  final Vector2 _identityVector2 = Vector2Extension.identity();

  /// Should be the center of that [offsetPosition] and [relativeOffset]
  /// should be calculated from, if they are not set this is the center of the
  /// shape
  Vector2 position = Vector2.zero();

  /// The size is the bounding box of the [Shape]
  Vector2 size;

  /// The scaled size of the bounding box of the [Shape], if no scaling of the
  /// parent is supported this will return [size].
  Vector2 get scale => _identityVector2;

  Vector2 get halfSize {
    if (!_halfSizeCache.isCacheValid([size])) {
      _halfSizeCache.updateCache(size / 2, [size.clone()]);
    }
    return _halfSizeCache.value!;
  }

  /// The angle of the shape from its initial definition
  double angle;

  /// The local position of your shape, so the diff from the [position] of the
  /// shape
  Vector2 offsetPosition = Vector2.zero();

  /// The position of your shape in relation to its size from (-1,-1) to (1,1)
  Vector2 relativeOffset = Vector2.zero();

  /// The [relativeOffset] converted to a length vector
  Vector2 get relativePosition {
    if (!_relativePositionCache.isCacheValid([size, relativeOffset])) {
      _relativePositionCache.updateCache(
        (size / 2)..multiply(relativeOffset),
        [size.clone(), relativeOffset.clone()],
      );
    }
    return _relativePositionCache.value!;
  }

  /// The angle of the parent that has to be taken into consideration for some
  /// applications of [Shape], for example [HitboxShape]
  double parentAngle = 0;

  /// Whether the context that the shape is in has already prepared (rotated
  /// and translated) the canvas before coming to the shape's render method.
  bool isCanvasPrepared = false;

  /// The center position of the shape within itself, without rotation
  Vector2 get localCenter {
    final stateValues = [
      size,
      relativeOffset,
      offsetPosition,
    ];
    if (!_localCenterCache.isCacheValid(stateValues)) {
      final center = (size / 2)
        ..add(relativePosition)
        ..add(offsetPosition);
      _localCenterCache.updateCache(
        center,
        stateValues.map((e) => e.clone()).toList(growable: false),
      );
    }
    return _localCenterCache.value!;
  }

  /// The shape's absolute center with rotation taken into account
  Vector2 get absoluteCenter {
    final stateValues = [
      position,
      offsetPosition,
      relativeOffset,
      angle,
      parentAngle,
    ];
    if (!_absoluteCenterCache.isCacheValid(stateValues)) {
      /// The center of the shape, before any rotation
      final center = position + offsetPosition;
      if (!relativeOffset.isZero()) {
        center.add(relativePosition);
      }
      if (angle != 0 || parentAngle != 0) {
        center.rotate(parentAngle + angle, center: position);
      }
      _absoluteCenterCache.updateCache(center, [
        position.clone(),
        offsetPosition.clone(),
        relativeOffset.clone(),
        angle,
        parentAngle,
      ]);
    }
    return _absoluteCenterCache.value!;
  }

  Shape({
    Vector2? position,
    Vector2? size,
    this.angle = 0,
  })  : position = position ?? Vector2.zero(),
        size = size ?? Vector2.zero();

  /// Whether the point [p] is within the shapes boundaries or not
  bool containsPoint(Vector2 p);

  void render(Canvas canvas, Paint paint);

  /// Where this [Shape] has intersection points with another shape
  Set<Vector2> intersections(Shape other) {
    return intersection_system.intersections(this, other);
  }
}

mixin HitboxShape on Shape {
  late PositionComponent component;

  @override
  bool isCanvasPrepared = true;

  @override
  Vector2 get size => component.size;

  @override
  Vector2 get scale => component.scale;

  @override
  double get parentAngle => component.absoluteAngle;

  @override
  Vector2 get position => component.absoluteCenter;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [HitboxShape].
  CollisionCallback onCollision = emptyCollisionCallback;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape starts to collide with another [HitboxShape].
  CollisionCallback onCollisionStart = emptyCollisionCallback;

  /// Assign your own [CollisionEndCallback] if you want a callback when this
  /// shape stops colliding with another [HitboxShape].
  CollisionEndCallback onCollisionEnd = emptyCollisionEndCallback;
}

typedef CollisionCallback = void Function(
  Set<Vector2> intersectionPoints,
  HitboxShape other,
);

typedef CollisionEndCallback = void Function(HitboxShape other);

void emptyCollisionCallback(Set<Vector2> _, HitboxShape __) {}
void emptyCollisionEndCallback(HitboxShape _) {}
