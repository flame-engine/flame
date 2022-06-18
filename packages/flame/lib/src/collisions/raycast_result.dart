import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/ray2.dart';

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
  late Ray2 ray;
  Vector2 get point => ray.origin;
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
}
