import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/ray2.dart';

/// The result of a raycasting operation.
///
/// Note that the members of this class is heavily re-used. If you want to
/// keep the result in an object, clone the parts you want, or the whole
/// [RaycastResult] with [clone].
class RaycastResult<T extends Hitbox<T>> {
  RaycastResult({this.hitbox, Ray2? ray, double? distance}) {
    if (ray != null) {
      this.ray = ray;
    }
    if (distance != null) {
      this.distance = distance;
    }
  }

  T? hitbox;
  Ray2? ray;
  Vector2? get point => ray?.origin;
  double distance = double.maxFinite;

  void setWith({T? hitbox, required Ray2 ray, double? distance}) {
    this.hitbox = hitbox;
    this.ray = ray;
    this.distance = distance ?? double.maxFinite;
  }

  void reset() {
    hitbox = null;
    distance = double.maxFinite;
  }

  void setFrom(RaycastResult<T> result) {
    hitbox = result.hitbox;
    ray = result.ray;
    distance = result.distance;
  }

  RaycastResult<T> clone() {
    return RaycastResult(hitbox: hitbox, ray: ray?.clone(), distance: distance);
  }
}
