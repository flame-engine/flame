import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/ray2.dart';
import 'package:meta/meta.dart';

/// The result of a raycasting operation.
///
/// Note that the members of this class is heavily re-used. If you want to
/// keep the result in an object, clone the parts you want, or the whole
/// [RaycastResult] with [clone].
class RaycastResult<T extends Hitbox<T>> {
  RaycastResult({
    T? hitbox,
    bool isInsideHitbox = false,
    Ray2? originatingRay,
    double? distance,
    Vector2? Function()? intersectionPointFunction,
    Vector2? Function()? normalFunction,
    Ray2? Function()? reflectionRayFunction,
  })  : _hitbox = hitbox,
        _isInsideHitbox = isInsideHitbox,
        rawOriginatingRay = originatingRay,
        _distance = distance,
        _intersectionPointFunction = intersectionPointFunction,
        _normalFunction = normalFunction,
        _reflectionRayFunction = reflectionRayFunction;

  T? get hitbox => isActive ? _hitbox : null;
  T? _hitbox;

  /// Whether this result has active results in it.
  ///
  /// This is used so that the objects in there can continue to live even when
  /// there is no result from a ray cast.
  bool get isActive => _hitbox != null;

  /// Whether the origin of the ray was inside the hitbox.
  bool get isInsideHitbox => _isInsideHitbox;
  bool _isInsideHitbox;

  /// The casted ray that the result came from.
  Ray2? get originatingRay => isActive ? rawOriginatingRay : null;
  @internal
  Ray2? rawOriginatingRay;

  Vector2? Function()? _intersectionPointFunction;
  Vector2? Function()? _normalFunction;
  Ray2? Function()? _reflectionRayFunction;

  double? _distance;
  double? get distance {
    return isActive ? _distance : null;
  }

  @internal
  Vector2? rawIntersectionPoint;
  bool _validIntersectionPoint = false;
  Vector2? get intersectionPoint {
    if (!isActive) {
      return null;
    }
    if (!_validIntersectionPoint) {
      rawIntersectionPoint = _intersectionPointFunction?.call();
      _validIntersectionPoint = true;
    }
    return rawIntersectionPoint;
  }

  @internal
  Vector2? rawNormal;
  bool _validNormal = false;
  Vector2? get normal {
    if (!isActive) {
      return null;
    }
    if (!_validNormal) {
      rawNormal = _normalFunction?.call();
      _validNormal = true;
    }
    return rawNormal;
  }

  @internal
  Ray2? rawReflectionRay;
  bool _validReflectionRay = false;
  Ray2? get reflectionRay {
    if (!isActive) {
      return null;
    }
    if (!_validReflectionRay) {
      rawReflectionRay = _reflectionRayFunction?.call();
      _validReflectionRay = true;
    }
    return rawReflectionRay;
  }

  /// Used for storing the center of the [CircleHitbox] to be able to lazily
  /// compute other values.
  @internal
  Vector2? hitboxCenter;

  void reset() {
    _hitbox = null;
    _validIntersectionPoint = false;
    _validNormal = false;
    _validReflectionRay = false;
  }

  /// Sets this [RaycastResult]'s objects to the values stored in [other].
  void setFrom(RaycastResult<T> other) {
    setWith(
      hitbox: other.hitbox,
      isInsideHitbox: other.isInsideHitbox,
      originatingRay: other.rawOriginatingRay,
      distance: other._distance,
      intersectionPointFunction: other._intersectionPointFunction,
      normalFunction: other._normalFunction,
      reflectionRayFunction: other._reflectionRayFunction,
    );
    _validIntersectionPoint = other._validIntersectionPoint;
    if (_validIntersectionPoint) {
      rawIntersectionPoint = (rawIntersectionPoint
            ?..setFrom(other.rawIntersectionPoint!)) ??
          other.rawIntersectionPoint!.clone();
    }

    _validNormal = other._validNormal;
    if (_validNormal) {
      rawNormal =
          (rawNormal?..setFrom(other.rawNormal!)) ?? other.rawNormal!.clone();
    }

    _validReflectionRay = other._validReflectionRay;
    if (_validReflectionRay) {
      rawReflectionRay = (rawReflectionRay
            ?..setFrom(other.rawReflectionRay!)) ??
          other.rawReflectionRay!.clone();
    }
  }

  /// Sets the values of the result from the specified arguments.
  ///
  /// Values that are not specified are kept as their previous values.
  void setWith({
    T? hitbox,
    bool? isInsideHitbox,
    Ray2? originatingRay,
    double? distance,
    Vector2? Function()? intersectionPointFunction,
    Vector2? Function()? normalFunction,
    Ray2? Function()? reflectionRayFunction,
  }) {
    _hitbox = hitbox ?? _hitbox;
    _distance = distance ?? _distance;
    _isInsideHitbox = isInsideHitbox ?? _isInsideHitbox;
    if (intersectionPointFunction != null) {
      _intersectionPointFunction = intersectionPointFunction;
      _validIntersectionPoint = false;
    }
    if (normalFunction != null) {
      _normalFunction = normalFunction;
      _validNormal = false;
    }
    if (reflectionRayFunction != null) {
      _reflectionRayFunction = reflectionRayFunction;
      _validReflectionRay = false;
    }
    if (rawOriginatingRay != null && originatingRay != null) {
      rawOriginatingRay?.setFrom(originatingRay);
    } else {
      rawOriginatingRay = originatingRay?.clone() ?? rawOriginatingRay;
    }
  }

  RaycastResult<T> clone() => RaycastResult<T>()..setFrom(this);
}
