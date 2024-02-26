import 'package:flame_3d/game.dart';

extension Aabb3Extension on Aabb3 {
  /// Set the min and max from the [other].
  void setFrom(Aabb3 other) {
    min.setFrom(other.min);
    max.setFrom(other.max);
  }

  /// Set the min and max to zero.
  void setZero() {
    min.setZero();
    max.setZero();
  }
}
