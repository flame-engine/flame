// ignore_for_file: comment_references

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
  }) : shouldFillParent = radius == null && position == null;

  /// With this constructor you define the [CircleHitbox] in relation to the
  /// [parentSize]. For example having a [relation] of 0.5 would create a circle
  /// that fills half of the [parentSize].
  CircleHitbox.relative(
    super.relation, {
    super.position,
    required super.parentSize,
    super.angle,
    super.anchor,
  })  : shouldFillParent = false,
        super.relative();

  @override
  void fillParent() {
    // There is no need to do anything here since the size already is bound to
    // the parent size and the radius is defined from the shortest side.
  }

  late final _temporaryLineSegment = LineSegment.zero();
  late final _temporaryNormal = Vector2.zero();
  late final _temporaryCenter = Vector2.zero();
  late final _temporaryAbsoluteCenter = Vector2.zero();

  @override
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  }) {
    var isInsideHitbox = false;
    _temporaryLineSegment.from.setFrom(ray.origin);
    _temporaryAbsoluteCenter.setFrom(absoluteCenter);
    _temporaryCenter
      ..setFrom(_temporaryAbsoluteCenter)
      ..sub(ray.origin);
    _temporaryCenter.projection(ray.direction, out: _temporaryLineSegment.to);
    _temporaryLineSegment.to
      ..x *= (ray.direction.x.sign * _temporaryLineSegment.to.x.sign)
      ..y *= (ray.direction.y.sign * _temporaryLineSegment.to.y.sign);
    if (_temporaryLineSegment.to.length2 < radius * radius) {
      _temporaryLineSegment.to.scaleTo(2 * radius);
      isInsideHitbox = true;
    }
    _temporaryLineSegment.to.add(ray.origin);
    final intersections = lineSegmentIntersections(_temporaryLineSegment).where(
      (i) => i.distanceToSquared(ray.origin) > 0.0000001,
    );
    if (intersections.isEmpty) {
      out?.reset();
      return null;
    } else {
      final result = out ?? RaycastResult();
      result.hitboxCenter = (result.hitboxCenter
            ?..setFrom(_temporaryAbsoluteCenter)) ??
          _temporaryAbsoluteCenter.clone();

      result.setWith(
        hitbox: this,
        isInsideHitbox: isInsideHitbox,
        intersectionPointFunction: () => intersections.first,
        distance:
            result.originatingRay?.origin.distanceTo(result.intersectionPoint!),
      );
      result.setWith(
        normalFunction: () =>
            _rayNormal(result, isInsideHitbox: isInsideHitbox),
      );
      result.setWith(
        reflectionRayFunction: () => _rayReflection(result),
      );
      return result;
    }
  }

  Vector2 _rayNormal(RaycastResult result, {required bool isInsideHitbox}) {
    _temporaryNormal
      ..setFrom(result.intersectionPoint!)
      ..sub(result.hitboxCenter!)
      ..normalize();
    if (isInsideHitbox) {
      _temporaryNormal.invert();
    }
    return _temporaryNormal;
  }

  Ray2 _rayReflection(RaycastResult result) {
    final intersectionPoint = result.intersectionPoint!;

    final reflectionDirection =
        (result.rawReflectionRay?.direction ?? Vector2.zero())
          ..setFrom(result.originatingRay!.direction)
          ..reflect(result.normal!);

    final reflectionRay = (result.rawReflectionRay
          ?..setWith(
            origin: intersectionPoint,
            direction: reflectionDirection,
          )) ??
        Ray2(intersectionPoint, reflectionDirection);
    return reflectionRay;
  }
}
