import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

/// A ray in the 2d plane.
///
/// The [direction] should be normalized.
class Ray2 {
  Ray2({required this.origin, required Vector2 direction}) {
    this.direction = direction;
  }

  Ray2.zero() : this(origin: Vector2.zero(), direction: Vector2(1, 0));

  /// The point where the ray originates from.
  Vector2 origin;

  /// The normalized direction of the ray.
  ///
  /// The values within the direction object should not be updated manually, use
  /// the setter instead.
  Vector2 get direction => _direction;
  set direction(Vector2 direction) {
    _direction.setFrom(direction);
    _updateInverses();
  }

  final Vector2 _direction = Vector2.zero();

  /// Should be called if the [direction] values are updated within the object
  /// instead of by the setter.
  void _updateInverses() {
    assert(
      (direction.length2 - 1).abs() < 0.000001,
      'direction must be normalized',
    );
    directionInvX = (1 / direction.x).toFinite();
    directionInvY = (1 / direction.y).toFinite();
  }

  // These are the inverse of the direction (the normal), they are used to avoid
  // a division in [intersectsWithAabb2], since a ray will usually be tried
  // against many bounding boxes it's good to pre-calculate it, which is done
  // in the direction setter.
  @visibleForTesting
  late double directionInvX;
  @visibleForTesting
  late double directionInvY;

  /// Whether the ray intersects the [box] or not.
  ///
  /// Rays that originate on the edge of the [box] are considered to be
  /// intersecting with the box no matter what direction they have.
  // This uses the Branchless Ray/Bounding box intersection method by Tavian,
  // but since +-infinity is replaced by +-maxFinite for directionInvX and
  // directionInvY, rays that originate on an edge will always be considered to
  // intersect with the aabb, no matter what direction they have.
  // https://tavianator.com/2011/ray_box.html
  // https://tavianator.com/2015/ray_box_nan.html
  bool intersectsWithAabb2(Aabb2 box) {
    final tx1 = (box.min.x - origin.x) * directionInvX;
    final tx2 = (box.max.x - origin.x) * directionInvX;

    final ty1 = (box.min.y - origin.y) * directionInvY;
    final ty2 = (box.max.y - origin.y) * directionInvY;

    final tMin = max(min(tx1, tx2), min(ty1, ty2));
    final tMax = min(max(tx1, tx2), max(ty1, ty2));

    return tMax >= max(tMin, 0);
  }

  /// Gives the point at a certain length along the ray.
  Vector2 point(double length, {Vector2? out}) {
    return ((out?..setFrom(origin)) ?? origin.clone())
      ..addScaled(direction, length);
  }

  static final Vector2 _v1 = Vector2.zero();
  static final Vector2 _v2 = Vector2.zero();
  static final Vector2 _v3 = Vector2.zero();

  /// Returns where (length wise) on the ray that the ray intersects the
  /// [LineSegment] or null if there is no intersection.
  ///
  /// A ray that is parallel and overlapping with the [segment] is considered to
  /// not intersect. This is due to that a single intersection point can't be
  /// determined and that a [LineSegment] is almost always connected to another
  /// line segment which will get the intersection on one of its ends instead.
  double? lineSegmentIntersection(LineSegment segment) {
    _v1
      ..setFrom(origin)
      ..sub(segment.from);
    _v2
      ..setFrom(segment.to)
      ..sub(segment.from);
    _v3.setValues(-direction.y, direction.x);

    final dot = _v2.dot(_v3);
    final t1 = _v2.cross(_v1) / dot;
    final t2 = _v1.dot(_v3) / dot;
    if (t1 >= 0 && t2 >= 0 && t2 <= 1) {
      return t1;
    }
    return null;
  }

  /// Deep clones the object, i.e. both [origin] and [direction] are cloned into
  /// a new [Ray2] object.
  Ray2 clone() => Ray2(origin: origin.clone(), direction: direction.clone());

  /// Sets the values by copying them from [other].
  void setFrom(Ray2 other) {
    setWith(origin: other.origin, direction: other.direction);
  }

  void setWith({required Vector2 origin, required Vector2 direction}) {
    this.origin.setFrom(origin);
    this.direction = direction;
  }

  @override
  String toString() => 'Ray2(origin: $origin, direction: $direction)';
}
