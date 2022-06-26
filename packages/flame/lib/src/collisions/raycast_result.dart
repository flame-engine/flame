import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/ray2.dart';

/// The result of a raycasting operation.
///
/// Note that the members of this class is heavily re-used. If you want to
/// keep the result in an object, clone the parts you want, or the whole
/// [RaycastResult] with [clone].
class RaycastResult<T extends Hitbox<T>> {
  RaycastResult({
    T? hitbox,
    Ray2? reflectionRay,
    Vector2? normal,
    double? distance,
    this.isActive = true,
  }) {
    _hitbox = hitbox;
    _reflectionRay = reflectionRay ?? Ray2.zero();
    _normal = normal ?? Vector2.zero();
    _distance = distance ?? double.maxFinite;
  }

  /// Whether this result has active results in it.
  ///
  /// This is used so that the objects in there can continue to live even when
  /// there is no result from a ray cast.
  bool isActive;

  T? _hitbox;
  T? get hitbox => isActive ? _hitbox : null;

  late Ray2 _reflectionRay;
  Ray2? get reflectionRay => isActive ? _reflectionRay : null;

  Vector2? get point => reflectionRay?.origin;

  late double _distance;
  double? get distance => isActive ? _distance : null;

  late Vector2 _normal;
  Vector2? get normal => isActive ? _normal : null;

  void reset() => isActive = false;

  /// Sets this [RaycastResult]'s objects to the values stored in [other].
  ///
  /// Always sets [isActive] to true, unless explicitly passed false.
  void setFrom(RaycastResult<T> other, {bool isActive = true}) {
    setWith(
      hitbox: other.hitbox,
      reflectionRay: other.reflectionRay,
      normal: other.normal,
      distance: other.distance,
      isActive: isActive,
    );
  }

  void setWith({
    T? hitbox,
    Ray2? reflectionRay,
    Vector2? normal,
    double? distance,
    bool isActive = true,
  }) {
    _hitbox = hitbox;
    if (reflectionRay != null) {
      _reflectionRay.setFrom(reflectionRay);
    }
    if (normal != null) {
      _normal.setFrom(normal);
    }
    _distance = distance ?? double.maxFinite;
    this.isActive = isActive;
  }

  RaycastResult<T> clone() {
    return RaycastResult(
      hitbox: hitbox,
      reflectionRay: _reflectionRay.clone(),
      normal: _normal.clone(),
      distance: distance,
      isActive: isActive,
    );
  }
}
