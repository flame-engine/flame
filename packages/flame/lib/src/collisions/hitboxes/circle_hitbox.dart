// ignore_for_file: comment_references

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

/// A [Hitbox] in the shape of a circle.
class CircleHitbox extends CircleComponent with ShapeHitbox {
  @override
  final bool shouldFillParent;

  CircleHitbox({
    super.radius,
    super.position,
    super.angle,
    super.anchor,
    bool isSolid = false,
    CollisionType collisionType = CollisionType.active,
  }) : shouldFillParent = radius == null && position == null {
    this.isSolid = isSolid;
    this.collisionType = collisionType;
  }

  /// With this constructor you define the [CircleHitbox] in relation to the
  /// [parentSize]. For example having a [relation] of 0.5 would create a circle
  /// that fills half of the [parentSize].
  CircleHitbox.relative(
    super.relation, {
    required super.parentSize,
    super.position,
    super.angle,
    super.anchor,
    bool isSolid = false,
    CollisionType collisionType = CollisionType.active,
  }) : shouldFillParent = false,
       super.relative() {
    this.isSolid = isSolid;
    this.collisionType = collisionType;
  }

  @override
  void fillParent() {
    // There is no need to do anything here since the size already is bound to
    // the parent size and the radius is defined from the shortest side.
  }

  static final _temporaryNormal = Vector2.zero();
  static final _temporaryCenter = Vector2.zero();
  static final _temporaryAbsoluteCenter = Vector2.zero();

  @override
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    final effectiveRadius = scaledRadius;
    _temporaryAbsoluteCenter.setFrom(absoluteCenter);

    // Solve ray-circle intersection analytically.
    // Ray: P + t*D where |D| = 1, Circle: |X - C|² = r²
    // Substituting: t² + bt + c = 0
    _temporaryCenter
      ..setFrom(ray.origin)
      ..sub(_temporaryAbsoluteCenter); // P - C
    final b = 2 * _temporaryCenter.dot(ray.direction);
    final c = _temporaryCenter.length2 - effectiveRadius * effectiveRadius;

    final discriminant = b * b - 4 * c;
    if (discriminant < 0) {
      out?.reset();
      return null;
    }

    final sqrtDiscriminant = sqrt(discriminant);
    final t1 = (-b - sqrtDiscriminant) / 2;
    final t2 = (-b + sqrtDiscriminant) / 2;

    // Use a radius-relative epsilon. Vector2 stores components in Float32List,
    // so coordinates near the boundary carry ~6 digits of precision. After
    // reflecting, the stored origin can be off by up to r*1e-4, producing a
    // spurious near-zero t from recomputing against the same circle.
    final epsilon = effectiveRadius * 1e-4;
    final double t;
    final bool isInsideHitbox;
    if (t1 > epsilon) {
      t = t1;
      isInsideHitbox = false;
    } else if (t2 > epsilon) {
      t = t2;
      isInsideHitbox = true;
    } else {
      out?.reset();
      return null;
    }

    // Intersection point = origin + t * direction.
    _temporaryCenter
      ..setFrom(ray.direction)
      ..scale(t)
      ..add(ray.origin);

    // Normal at intersection: direction from center to hit point.
    _temporaryNormal
      ..setFrom(_temporaryCenter)
      ..sub(_temporaryAbsoluteCenter)
      ..normalize();

    // Snap intersection to exact boundary to prevent numerical drift.
    _temporaryCenter
      ..setFrom(_temporaryNormal)
      ..scale(effectiveRadius)
      ..add(_temporaryAbsoluteCenter);

    if (isInsideHitbox) {
      _temporaryNormal.invert();
    }

    final result = out ?? RaycastResult();
    final reflectionDirection =
        (out?.reflectionRay?.direction ?? Vector2.zero())
          ..setFrom(ray.direction)
          ..reflect(_temporaryNormal);
    reflectionDirection.normalize();

    final reflectionRay =
        (out?.reflectionRay?..setWith(
          origin: _temporaryCenter,
          direction: reflectionDirection,
        )) ??
        Ray2(
          origin: _temporaryCenter,
          direction: reflectionDirection,
        );

    result.setWith(
      hitbox: this,
      reflectionRay: reflectionRay,
      normal: _temporaryNormal,
      distance: t, // |D| = 1, so parametric t equals Euclidean distance
      isInsideHitbox: isInsideHitbox,
    );
    return result;
  }
}
