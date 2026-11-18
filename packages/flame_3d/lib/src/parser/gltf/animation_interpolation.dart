import 'dart:math' as math;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Interpolation algorithm.
enum AnimationInterpolation(final String value) {
  /// The animated values are linearly interpolated between keyframes.
  linear('LINEAR'),

  /// The animated values remain constant until the next keyframe.
  step('STEP'),

  /// Cubic Hermite spline interpolation (supports both glTF `3 * K`
  /// `(inTangent, value, outTangent)` triplets and zero-tangent smoothstep
  /// curves when `values.length == times.length`).
  cubicSpline('CUBICSPLINE'); // cSpell:ignore CUBICSPLINE

  static AnimationInterpolation valueOf(String value) {
    return values.firstWhere((e) => e.value == value);
  }

  static AnimationInterpolation? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }

  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    final out = Vector3.zero();
    lerpInto(a, b, t, out);
    return out;
  }

  /// Writes the interpolated vector between [a] and [b] at [t] into [out]
  /// without allocating.
  void lerpInto(Vector3 a, Vector3 b, double t, Vector3 out) {
    switch (this) {
      case linear:
        out.setValues(
          a.x + (b.x - a.x) * t,
          a.y + (b.y - a.y) * t,
          a.z + (b.z - a.z) * t,
        );
      case step:
        out.setFrom(a);
      case cubicSpline:
        final u = t * t * (3.0 - 2.0 * t);
        out.setValues(
          a.x + (b.x - a.x) * u,
          a.y + (b.y - a.y) * u,
          a.z + (b.z - a.z) * u,
        );
    }
  }

  Quaternion slerp(Quaternion a, Quaternion b, double t) {
    final out = Quaternion.identity();
    slerpInto(a, b, t, out);
    return out;
  }

  /// Writes the shortest-arc spherical interpolation between [a] and [b] at
  /// [t] into [out] without allocating.
  void slerpInto(Quaternion a, Quaternion b, double t, Quaternion out) {
    switch (this) {
      case linear:
        slerpQuaternionsInto(a, b, t, out);
      case step:
        out.setFrom(a);
      case cubicSpline:
        final u = t * t * (3.0 - 2.0 * t);
        slerpQuaternionsInto(a, b, u, out);
    }
  }

  /// Evaluates a glTF 2.0 `CUBICSPLINE` `Vector3` segment `[v0..v1]` with
  /// outgoing tangent [b0], incoming tangent [a1], segment duration [dt], and
  /// normalized parameter [t] into [out].
  static void cubicHermiteVector3Into(
    Vector3 v0,
    Vector3 b0,
    Vector3 v1,
    Vector3 a1,
    double dt,
    double t,
    Vector3 out,
  ) {
    final t2 = t * t;
    final t3 = t2 * t;
    final h00 = 2.0 * t3 - 3.0 * t2 + 1.0;
    final h10 = (t3 - 2.0 * t2 + t) * dt;
    final h01 = -2.0 * t3 + 3.0 * t2;
    final h11 = (t3 - t2) * dt;
    out.setValues(
      h00 * v0.x + h10 * b0.x + h01 * v1.x + h11 * a1.x,
      h00 * v0.y + h10 * b0.y + h01 * v1.y + h11 * a1.y,
      h00 * v0.z + h10 * b0.z + h01 * v1.z + h11 * a1.z,
    );
  }

  /// Evaluates a glTF 2.0 `CUBICSPLINE` `Quaternion` segment and normalizes the
  /// result into [out].
  static void cubicHermiteQuaternionInto(
    Quaternion v0,
    Quaternion b0,
    Quaternion v1,
    Quaternion a1,
    double dt,
    double t,
    Quaternion out,
  ) {
    final t2 = t * t;
    final t3 = t2 * t;
    final h00 = 2.0 * t3 - 3.0 * t2 + 1.0;
    final h10 = (t3 - 2.0 * t2 + t) * dt;
    final h01 = -2.0 * t3 + 3.0 * t2;
    final h11 = (t3 - t2) * dt;
    var rx = h00 * v0.x + h10 * b0.x + h01 * v1.x + h11 * a1.x;
    var ry = h00 * v0.y + h10 * b0.y + h01 * v1.y + h11 * a1.y;
    var rz = h00 * v0.z + h10 * b0.z + h01 * v1.z + h11 * a1.z;
    var rw = h00 * v0.w + h10 * b0.w + h01 * v1.w + h11 * a1.w;
    final len = math.sqrt(rx * rx + ry * ry + rz * rz + rw * rw);
    if (len > 1e-12) {
      final inv = 1.0 / len;
      rx *= inv;
      ry *= inv;
      rz *= inv;
      rw *= inv;
    }
    out.setValues(rx, ry, rz, rw);
  }

  /// Allocation-free shortest-arc quaternion SLERP into [out].
  static void slerpQuaternionsInto(
    Quaternion a,
    Quaternion b,
    double t,
    Quaternion out,
  ) {
    final ax = a.x;
    final ay = a.y;
    final az = a.z;
    final aw = a.w;
    var bx = b.x;
    var by = b.y;
    var bz = b.z;
    var bw = b.w;

    var cosHalfTheta = ax * bx + ay * by + az * bz + aw * bw;
    if (cosHalfTheta < 0.0) {
      cosHalfTheta = -cosHalfTheta;
      bx = -bx;
      by = -by;
      bz = -bz;
      bw = -bw;
    }

    double s0;
    double s1;
    if (1.0 - cosHalfTheta > 1e-5) {
      final halfTheta = math.acos(cosHalfTheta.clamp(-1.0, 1.0));
      final invSin = 1.0 / math.sin(halfTheta);
      s0 = math.sin((1.0 - t) * halfTheta) * invSin;
      s1 = math.sin(t * halfTheta) * invSin;
    } else {
      s0 = 1.0 - t;
      s1 = t;
    }

    var rx = s0 * ax + s1 * bx;
    var ry = s0 * ay + s1 * by;
    var rz = s0 * az + s1 * bz;
    var rw = s0 * aw + s1 * bw;
    final len = math.sqrt(rx * rx + ry * ry + rz * rz + rw * rw);
    if (len > 1e-12) {
      final inv = 1.0 / len;
      rx *= inv;
      ry *= inv;
      rz *= inv;
      rw *= inv;
    }
    out.setValues(rx, ry, rz, rw);
  }
}
