import 'dart:math' as math;

import 'package:flame_3d/game.dart';

extension Aabb3Extension on Aabb3 {
  /// Merge [other] with this.
  void merge(Aabb3 other) {
    min.setValues(
      math.min(min.x, other.min.x),
      math.min(min.y, other.min.y),
      math.min(min.z, other.min.z),
    );
    max.setValues(
      math.max(max.x, other.max.x),
      math.max(max.y, other.max.y),
      math.max(max.z, other.max.z),
    );
  }

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
