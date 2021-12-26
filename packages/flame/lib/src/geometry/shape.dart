import '../../components.dart';
import '../components/cache/value_cache.dart';

/// A shape can represent any geometrical shape with optionally a size, position
/// and angle. It can also have an anchor if it shouldn't be rotated around its
/// center.
/// A point can be determined to be within of outside of a shape.
abstract class Shape extends PositionComponent with HasPaint {
  final ValueCache<Vector2> _halfSizeCache = ValueCache();
  final ValueCache<Vector2> _localCenterCache = ValueCache();
  final ValueCache<Vector2> _absoluteCenterCache = ValueCache();
  final ValueCache<Vector2> _relativePositionCache = ValueCache();

  // These are used to avoid creating new vector objects on some method calls
  final Vector2 _identityVector2 = Vector2Extension.identity();

  /// The local position of your shape, so the diff from the [position] of the
  /// shape.
  Vector2 offsetPosition;

  /// The position of your shape in relation to its size from (-1,-1) to (1,1).
  Vector2 relativeOffset;

  Shape({
    Vector2? offsetPosition,
    Vector2? relativeOffset,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  })  : offsetPosition = offsetPosition ?? Vector2.zero(),
        relativeOffset = relativeOffset ?? Vector2.zero(),
        super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  Vector2 get halfSize {
    if (!_halfSizeCache.isCacheValid([size])) {
      _halfSizeCache.updateCache(size / 2, [size.clone()]);
    }
    return _halfSizeCache.value!;
  }

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
  @override
  Vector2 get absoluteCenter {
    final stateValues = <dynamic>[
      position,
      offsetPosition,
      relativeOffset,
      absoluteAngle,
    ];
    if (!_absoluteCenterCache.isCacheValid<dynamic>(stateValues)) {
      /// The center of the shape, before any rotation
      final center = position + offsetPosition;
      if (!relativeOffset.isZero()) {
        center.add(relativePosition);
      }
      if (absoluteAngle != 0) {
        center.rotate(absoluteAngle, center: position);
      }
      _absoluteCenterCache.updateCache(center, [
        position.clone(),
        offsetPosition.clone(),
        relativeOffset.clone(),
        absoluteAngle,
      ]);
    }
    return _absoluteCenterCache.value!;
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
