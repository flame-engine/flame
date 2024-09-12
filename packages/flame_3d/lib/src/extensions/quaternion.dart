import 'dart:math';

import 'package:flame_3d/core.dart';

extension QuaternionExtension on Quaternion {
  List<double> get storage => [x, y, z, w];

  double dot(Quaternion other) {
    return x * other.x + y * other.y + z * other.z + w * other.w;
  }

  Quaternion lerp(Quaternion other, double t) {
    return QuaternionUtils.lerp(this, other, t);
  }

  Quaternion slerp(Quaternion other, double t, {double epsilon = 10e-6}) {
    return QuaternionUtils.slerp(this, other, t, epsilon: epsilon);
  }
}

final class QuaternionUtils {
  QuaternionUtils._();

  static Quaternion slerp(
    Quaternion q0,
    Quaternion q1,
    double t, {
    double epsilon = 10e-6,
  }) {
    final result = _slerp(q0, q1, t, epsilon: epsilon);
    if (result.storage.any((e) => e.isNaN || e.isInfinite)) {
      throw Exception(
        'Quaternion slerp result is invalid: slerp($q0, $q1) = $result',
      );
    }
    return result;
  }

  /// Some background on the correct shortest-path implementation can be found
  /// here:
  /// https://blog.magnum.graphics/backstage/the-unnecessarily-short-ways-to-do-a-quaternion-slerp/
  static Quaternion _slerp(
    Quaternion q0,
    Quaternion q1,
    double t, {
    double epsilon = 10e-6,
  }) {
    if (isEqual(q0, q1)) {
      return q0;
    }

    final dot = q0.dot(q1);
    if (1 - dot < epsilon) {
      // The quaternions are very close, so the linear interpolation algorithm
      // will be a good approximation.
      // This will prevent a NaN from the slerp algorithm.
      return lerp(q0, q1, t);
    }

    final angle = acos(dot.abs());

    final q1Prime = dot >= 0 ? q1 : q1.scaled(-1);
    final a = sin((1 - t) * angle) / sin(angle);
    final b = sin(t * angle) / sin(angle);

    return q0.scaled(a) + q1Prime.scaled(b);
  }

  static Quaternion lerp(Quaternion q0, Quaternion q1, double t) {
    return q0 + (q1 - q0).scaled(t);
  }

  static bool isEqual(Quaternion a, Quaternion b) {
    return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
  }
}
