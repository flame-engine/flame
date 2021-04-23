import 'dart:ui';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'shape_intersections.dart' as intersection_system;

/// A shape can represent any geometrical shape with optionally a size, position
/// and angle. It can also have an anchor if it shouldn't be rotated around its
/// center.
/// A point can be determined to be within of outside of a shape.
abstract class Shape {
  /// Should be the center of that [offsetPosition] and [relativeOffset]
  /// should be calculated from, if they are not set this is the center of the
  /// shape
  Vector2 position = Vector2.zero();

  /// The size is the bounding box of the [Shape]
  Vector2 size;

  /// The angle of the shape from its initial definition
  double angle;

  /// The local position of your shape, so the diff from the [position] of the
  /// shape
  Vector2 offsetPosition = Vector2.zero();

  /// The position of your shape in relation to its size
  Vector2 relativeOffset = Vector2.zero();

  /// The [relativeOffset] converted to a vector
  Vector2 get relativePosition => (size / 2)..multiply(relativeOffset);

  /// The angle of the parent that has to be taken into consideration for some
  /// applications of [Shape], for example [HitboxShape]
  double parentAngle;

  /// The center of the shape, before any rotation
  Vector2 unrotatedCenter() =>
      position.clone()..add(offsetPosition)..add(relativePosition);

  /// The center position of the shape within itself, without rotation
  Vector2 get localCenter =>
      (size / 2)..add(relativePosition)..add(offsetPosition);

  /// The shape's absolute center with rotation taken into account
  Vector2 get absoluteCenter {
    if (angle == 0 && relativeOffset.isZero()) {
      return position + offsetPosition;
    } else {
      return unrotatedCenter()..rotate(parentAngle + angle, center: position);
    }
  }

  /// Whether the canvas has been translated or not when it comes to rendering
  /// the shape
  final bool isTranslated = false;

  Shape({
    Vector2? position,
    Vector2? size,
    this.angle = 0,
    this.parentAngle = 0,
  })  : position = position ?? Vector2.zero(),
        size = size ?? Vector2.zero();

  /// Whether the point [p] is within the shapes boundaries or not
  bool containsPoint(Vector2 p);

  void render(Canvas c, Paint paint);

  /// Where this Shape has intersection points with another shape
  Set<Vector2> intersections(Shape other) {
    return intersection_system.intersections(this, other);
  }
}

mixin HitboxShape on Shape {
  late PositionComponent component;

  @override
  final bool isTranslated = true;

  @override
  Vector2 get size => component.size;

  @override
  double get parentAngle => component.angle;

  @override
  Vector2 get position => component.absoluteCenter;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [HitboxShape]
  CollisionCallback onCollision = emptyCollisionCallback;
}

typedef CollisionCallback = void Function(
  Set<Vector2> intersectionPoints,
  HitboxShape other,
);

void emptyCollisionCallback(Set<Vector2> _, HitboxShape __) {}

/// Used for caching calculated shapes, the cache is determined to be valid by
/// comparing a list of values that can be of any type and is compared to the
/// values that was last used when the cache was updated.
class ShapeCache<T> {
  T? value;

  List<dynamic> _lastValidCacheValues = <dynamic>[];

  ShapeCache();

  bool isCacheValid<F>(List<F> validCacheValues) {
    if (value == null) {
      return false;
    }
    for (var i = 0; i < _lastValidCacheValues.length; ++i) {
      if (_lastValidCacheValues[i] != validCacheValues[i]) {
        return false;
      }
    }
    return true;
  }

  T updateCache<F>(T value, List<F> validCacheValues) {
    this.value = value;
    _lastValidCacheValues = validCacheValues;
    return value;
  }
}
