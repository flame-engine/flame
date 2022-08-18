import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/ray2.dart';

/// The result of a raycasting operation.
///
/// Note that the members of this class is heavily re-used. If you want to
/// keep the result in an object, clone the parts you want, or the whole
/// [RaycastResult] with [clone].
///
/// NOTE: This class might be subject to breaking changes in an upcoming
/// version, to make it possible to calculate the values lazily.
class RaycastResult<T extends Hitbox<T>> {
  RaycastResult({
    T? hitbox,
    Ray2? reflectionRay,
    Vector2? normal,
    double? distance,
    bool isInsideHitbox = false,
  })  : _isInsideHitbox = isInsideHitbox,
        _hitbox = hitbox,
        _reflectionRay = reflectionRay ?? Ray2.zero(),
        _normal = normal ?? Vector2.zero(),
        _distance = distance ?? double.maxFinite;

  /// Whether this result has active results in it.
  ///
  /// This is used so that the objects in there can continue to live even when
  /// there is no result from a ray cast.
  bool get isActive => _hitbox != null;

  /// Whether the origin of the ray was inside the hitbox.
  bool get isInsideHitbox => _isInsideHitbox;
  bool _isInsideHitbox;

  T? _hitbox;
  T? get hitbox => isActive ? _hitbox : null;

  final Ray2 _reflectionRay;
  Ray2? get reflectionRay => isActive ? _reflectionRay : null;

  Vector2? get intersectionPoint => reflectionRay?.origin;

  double _distance;
  double? get distance => isActive ? _distance : null;

  final Vector2 _normal;
  Vector2? get normal => isActive ? _normal : null;

  void reset() => _hitbox = null;

  /// Sets this [RaycastResult]'s objects to the values stored in [other].
  void setFrom(RaycastResult<T> other) {
    setWith(
      hitbox: other.hitbox,
      reflectionRay: other.reflectionRay,
      normal: other.normal,
      distance: other.distance,
      isInsideHitbox: other.isInsideHitbox,
    );
  }

  /// Sets the values of the result from the specified arguments.
  void setWith({
    T? hitbox,
    Ray2? reflectionRay,
    Vector2? normal,
    double? distance,
    bool isInsideHitbox = false,
  }) {
    _hitbox = hitbox;
    if (reflectionRay != null) {
      _reflectionRay.setFrom(reflectionRay);
    }
    if (normal != null) {
      _normal.setFrom(normal);
    }
    _distance = distance ?? double.maxFinite;
    _isInsideHitbox = isInsideHitbox;
  }

  RaycastResult<T> clone() {
    return RaycastResult(
      hitbox: hitbox,
      reflectionRay: _reflectionRay.clone(),
      normal: _normal.clone(),
      distance: distance,
      isInsideHitbox: isInsideHitbox,
    );
  }
}
