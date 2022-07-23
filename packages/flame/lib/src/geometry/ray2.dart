import 'dart:math';

import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// A Ray is a ray in the 2d plane.
///
/// The [direction] should be normalized.
class Ray2 {
  Ray2(this.origin, Vector2 direction) {
    this.direction = direction;
  }

  Ray2.empty() : this(Vector2.zero(), Vector2(1, 0));

  Vector2 origin;
  late Vector2 _direction;
  Vector2 get direction => _direction;
  set direction(Vector2 direction) {
    assert(
      direction.x.abs() <= 1 && direction.y.abs() <= 1,
      'direction must be normalized',
    );
    _direction = direction;
    directionInvX = 1 / direction.x;
    directionInvY = 1 / direction.y;
  }

  // These are the inverse of the direction (the normal), they are used to avoid
  // a division in [intersectsWithAabb2], since a ray will usually be tried
  // against many bounding boxes it's good to pre-calculate it, which is done
  // in the direction setter.
  @visibleForTesting
  late double directionInvX;
  @visibleForTesting
  late double directionInvY;

  // Uses the branchless Ray/Bounding box intersection method by Tavian.
  // https://tavianator.com/2011/ray_box.html
  bool intersectsWithAabb2(Aabb2 box) {
    final tx1 = (box.min.x - origin.x) * directionInvX;
    final tx2 = (box.max.x - origin.x) * directionInvX;

    var tMin = min(tx1, tx2);
    var tMax = max(tx1, tx2);

    final ty1 = (box.min.y - origin.y) * directionInvY;
    final ty2 = (box.max.y - origin.y) * directionInvY;

    tMin = max(tMin, min(ty1, ty2));
    tMax = min(tMax, max(ty1, ty2));

    return tMax >= tMin;
  }

  /// Gives the point at a certain length of the ray.
  Vector2 point(double length, {Vector2? out}) {
    return ((out?..setFrom(direction)) ?? direction.clone())
      ..scale(length)
      ..add(origin);
  }

  late final Vector2 _v1 = Vector2.zero();
  late final Vector2 _v2 = Vector2.zero();
  late final Vector2 _v3 = Vector2.zero();
  double? lineSegmentIntersection(LineSegment segment) {
    _v1
      ..setFrom(origin)
      ..sub(segment.from);
    _v2
      ..setFrom(segment.to)
      ..sub(segment.from);
    _v3.setValues(-direction.y, direction.x);

    final dot = _v2.dot(_v3);
    if (dot.abs() < 0.000001) {
      return null;
    }

    final t1 = _v2.cross(_v1) / dot;
    final t2 = _v1.dot(_v3) / dot;
    if (t1 >= 0 && (t2 >= 0 && t2 <= 1)) {
      return t1;
    }
    return null;
  }

  /// Deep clones the object, i.e. both [origin] and [direction] are cloned into
  /// a new [Ray2] object.
  Ray2 clone() => Ray2(origin.clone(), direction.clone());

  void setFrom(Ray2 other) {
    setWith(origin: other.origin, direction: other.direction);
  }

  void setWith({required Vector2 origin, required Vector2 direction}) {
    this.origin.setFrom(origin);
    this.direction = direction;
  }
}
