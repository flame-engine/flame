import 'dart:math';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/parser/gltf/animation_interpolation.dart';

/// A single keyframe inside an animation; [T] is the type of value being
/// animated.
typedef AnimationKeyframe<T> = ({double time, T value});

/// Base class for animation splines. Animations are a sequence of
/// keyframes over either:
/// * position ([TranslationAnimationSpline]),
/// * angle ([RotationAnimationSpline]),
/// * scale ([ScaleAnimationSpline]).
abstract class AnimationSpline<T> {
  final AnimationInterpolation interpolation;
  final List<AnimationKeyframe<T>> values;

  /// Optional glTF `CUBICSPLINE` incoming/outgoing tangents (`values.length`
  /// entries each when present).
  final List<T>? inTangents;
  final List<T>? outTangents;

  AnimationSpline({
    required this.interpolation,
    required this.values,
    this.inTangents,
    this.outTangents,
  });

  AnimationSpline.from({
    required this.interpolation,
    required List<double> times,
    required List<T> values,
  }) : inTangents =
           interpolation == AnimationInterpolation.cubicSpline &&
               values.length == times.length * 3 &&
               times.isNotEmpty
           ? List.generate(times.length, (i) => values[i * 3])
           : null,
       outTangents =
           interpolation == AnimationInterpolation.cubicSpline &&
               values.length == times.length * 3 &&
               times.isNotEmpty
           ? List.generate(times.length, (i) => values[i * 3 + 2])
           : null,
       values = List.generate(times.length, (index) {
         final val =
             interpolation == AnimationInterpolation.cubicSpline &&
                 values.length == times.length * 3
             ? values[index * 3 + 1]
             : values[index];
         return (time: times[index], value: val);
       });

  T lerp(T a, T b, double t);
  void transform(Matrix4 matrix, T value);

  /// Applies the interpolated channel value between [a] and [b] at [t] directly
  /// into the TRS components `(translation, rotation, scale)` without
  /// allocating.
  void applyTrs(
    T a,
    T b,
    double t,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  );

  /// Applies cubic Hermite segment `i -> i + 1` when explicit tangents exist.
  void applyCubicSegmentTrs(
    int i,
    double dt,
    double t,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    applyTrs(
      values[i].value,
      values[i + 1].value,
      t,
      translation,
      rotation,
      scale,
    );
  }
}

/// An animation spline over the position of a transformation (translation).
class TranslationAnimationSpline.from({
  required super.interpolation,
  required super.times,
  required super.values,
}) extends AnimationSpline<Vector3> {
  this : super.from();

  @override
  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return interpolation.lerp(a, b, t);
  }

  @override
  void transform(Matrix4 matrix, Vector3 value) {
    matrix.setTranslation(value);
  }

  @override
  void applyTrs(
    Vector3 a,
    Vector3 b,
    double t,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    interpolation.lerpInto(a, b, t, translation);
  }

  @override
  void applyCubicSegmentTrs(
    int i,
    double dt,
    double t,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    final inT = inTangents;
    final outT = outTangents;
    if (inT != null && outT != null) {
      AnimationInterpolation.cubicHermiteVector3Into(
        values[i].value,
        outT[i],
        values[i + 1].value,
        inT[i + 1],
        dt,
        t,
        translation,
      );
    } else {
      super.applyCubicSegmentTrs(i, dt, t, translation, rotation, scale);
    }
  }
}

/// An animation spline over the angle of a transformation (rotation).
class RotationAnimationSpline.from({
  required super.interpolation,
  required super.times,
  required super.values,
}) extends AnimationSpline<Quaternion> {
  this : super.from();

  @override
  Quaternion lerp(Quaternion a, Quaternion b, double t) {
    return interpolation.slerp(a, b, t);
  }

  @override
  void transform(Matrix4 matrix, Quaternion value) {
    matrix.setRotation(value.asRotationMatrix());
  }

  @override
  void applyTrs(
    Quaternion a,
    Quaternion b,
    double t,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    interpolation.slerpInto(a, b, t, rotation);
  }

  @override
  void applyCubicSegmentTrs(
    int i,
    double dt,
    double t,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    final inT = inTangents;
    final outT = outTangents;
    if (inT != null && outT != null) {
      AnimationInterpolation.cubicHermiteQuaternionInto(
        values[i].value,
        outT[i],
        values[i + 1].value,
        inT[i + 1],
        dt,
        t,
        rotation,
      );
    } else {
      super.applyCubicSegmentTrs(i, dt, t, translation, rotation, scale);
    }
  }
}

/// An animation spline over the scale of a transformation (scaling).
class ScaleAnimationSpline.from({
  required super.interpolation,
  required super.times,
  required super.values,
}) extends AnimationSpline<Vector3> {
  this : super.from();

  @override
  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return interpolation.lerp(a, b, t);
  }

  @override
  void transform(Matrix4 matrix, Vector3 value) {
    matrix.scaleByVector3(value);
  }

  @override
  void applyTrs(
    Vector3 a,
    Vector3 b,
    double t,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    interpolation.lerpInto(a, b, t, scale);
  }

  @override
  void applyCubicSegmentTrs(
    int i,
    double dt,
    double t,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    final inT = inTangents;
    final outT = outTangents;
    if (inT != null && outT != null) {
      AnimationInterpolation.cubicHermiteVector3Into(
        values[i].value,
        outT[i],
        values[i + 1].value,
        inT[i + 1],
        dt,
        t,
        scale,
      );
    } else {
      super.applyCubicSegmentTrs(i, dt, t, translation, rotation, scale);
    }
  }
}

/// Allows sampling of an animation by interpolating keyframes in `O(log K)`.
class AnimationController<T>({
  required final AnimationSpline<T> animation,
}) {
  final double lastTime = animation.values.isEmpty
      ? 0.0
      : animation.values.last.time;

  T sample(double time) {
    final values = animation.values;
    if (values.length == 1 || time <= values.first.time) {
      return values.first.value;
    }
    if (time >= values.last.time) {
      return values.last.value;
    }
    final i = _segmentIndex(values, time);
    final t0 = values[i].time;
    final t1 = values[i + 1].time;
    final span = t1 - t0;
    final t = span > 1e-12 ? (time - t0) / span : 0.0;
    return animation.lerp(values[i].value, values[i + 1].value, t);
  }

  void sampleInto(double time, Matrix4 matrix) {
    final value = sample(time);
    animation.transform(matrix, value);
  }

  /// Samples the channel at [time] straight into `(translation, rotation,
  /// scale)` with zero heap allocations.
  void sampleTrsInto(
    double time,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    final values = animation.values;
    if (values.isEmpty) {
      return;
    }
    if (values.length == 1 || time <= values.first.time) {
      final first = values.first.value;
      animation.applyTrs(first, first, 0.0, translation, rotation, scale);
      return;
    }
    if (time >= values.last.time) {
      final last = values.last.value;
      animation.applyTrs(last, last, 0.0, translation, rotation, scale);
      return;
    }
    final i = _segmentIndex(values, time);
    final t0 = values[i].time;
    final t1 = values[i + 1].time;
    final span = t1 - t0;
    final t = span > 1e-12 ? (time - t0) / span : 0.0;
    if (animation.interpolation == AnimationInterpolation.cubicSpline &&
        animation.inTangents != null) {
      animation.applyCubicSegmentTrs(
        i,
        span,
        t,
        translation,
        rotation,
        scale,
      );
      return;
    }
    animation.applyTrs(
      values[i].value,
      values[i + 1].value,
      t,
      translation,
      rotation,
      scale,
    );
  }

  static int _segmentIndex<T>(List<AnimationKeyframe<T>> values, double time) {
    var lo = 0;
    var hi = values.length - 2;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (time < values[mid].time) {
        hi = mid - 1;
      } else if (time >= values[mid + 1].time) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }
    return lo.clamp(0, values.length - 2);
  }
}

/// Keyframed morph-target weight track (`AnimationPath.weights`).
class MorphWeightsChannel({
  required final AnimationInterpolation interpolation,
  required final List<double> times,
  required final List<double> weights,
  required final int targetCount,
}) {
  double get lastTime => times.isEmpty ? 0.0 : times.last;

  /// Samples the [targetCount] morph weights at [time] into [out].
  void sampleInto(double time, List<double> out) {
    if (times.isEmpty || targetCount <= 0 || out.length < targetCount) {
      return;
    }
    final cubicTriplets =
        interpolation == AnimationInterpolation.cubicSpline &&
        weights.length == times.length * targetCount * 3;
    int baseOf(int keyIdx) =>
        cubicTriplets ? (keyIdx * 3 + 1) * targetCount : keyIdx * targetCount;

    if (times.length == 1 || time <= times.first) {
      final b = baseOf(0);
      for (var k = 0; k < targetCount; k++) {
        out[k] = weights[b + k];
      }
      return;
    }
    if (time >= times.last) {
      final b = baseOf(times.length - 1);
      for (var k = 0; k < targetCount; k++) {
        out[k] = weights[b + k];
      }
      return;
    }

    var lo = 0;
    var hi = times.length - 2;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (time < times[mid]) {
        hi = mid - 1;
      } else if (time >= times[mid + 1]) {
        lo = mid + 1;
      } else {
        lo = mid;
        break;
      }
    }
    final i = lo.clamp(0, times.length - 2);
    final dt = times[i + 1] - times[i];
    final t = dt > 1e-12 ? (time - times[i]) / dt : 0.0;

    if (interpolation == AnimationInterpolation.step) {
      final b = baseOf(i);
      for (var k = 0; k < targetCount; k++) {
        out[k] = weights[b + k];
      }
      return;
    }

    if (cubicTriplets) {
      final t2 = t * t;
      final t3 = t2 * t;
      final h00 = 2.0 * t3 - 3.0 * t2 + 1.0;
      final h10 = (t3 - 2.0 * t2 + t) * dt;
      final h01 = -2.0 * t3 + 3.0 * t2;
      final h11 = (t3 - t2) * dt;
      final v0Base = (i * 3 + 1) * targetCount;
      final b0Base = (i * 3 + 2) * targetCount;
      final a1Base = ((i + 1) * 3) * targetCount;
      final v1Base = ((i + 1) * 3 + 1) * targetCount;
      for (var k = 0; k < targetCount; k++) {
        out[k] =
            h00 * weights[v0Base + k] +
            h10 * weights[b0Base + k] +
            h01 * weights[v1Base + k] +
            h11 * weights[a1Base + k];
      }
      return;
    }

    final u = interpolation == AnimationInterpolation.cubicSpline
        ? t * t * (3.0 - 2.0 * t)
        : t;
    final b0 = baseOf(i);
    final b1 = baseOf(i + 1);
    for (var k = 0; k < targetCount; k++) {
      final v0 = weights[b0 + k];
      out[k] = v0 + (weights[b1 + k] - v0) * u;
    }
  }
}

/// Groups the animations of a single node in a `Model`, which can be
/// controlled by multiple animation channels.
class NodeAnimation({
  required final List<AnimationController> channels,
  final MorphWeightsChannel? morphWeights,
}) {
  final double lastTime = _computeLastTime(channels, morphWeights);

  static double _computeLastTime(
    List<AnimationController> channels,
    MorphWeightsChannel? morph,
  ) {
    var best = morph?.lastTime ?? 0.0;
    for (final c in channels) {
      if (c.lastTime > best) {
        best = c.lastTime;
      }
    }
    return best;
  }

  void sampleInto(double time, Matrix4 matrix) {
    for (final channel in channels) {
      channel.sampleInto(time, matrix);
    }
  }

  /// Samples all channels for [time] into `(translation, rotation, scale)`
  /// starting from the node's rest TRS.
  void sampleTrsInto(
    double time,
    Vector3 translation,
    Quaternion rotation,
    Vector3 scale,
  ) {
    for (var i = 0; i < channels.length; i++) {
      channels[i].sampleTrsInto(time, translation, rotation, scale);
    }
  }
}

/// Timed event marker along a [ModelAnimation] clip timeline (with [time] in
/// seconds within `[0..duration]`).
class AnimationEvent3D({
  required final String name,
  required final double time,
  final Object? payload,
});

/// Groups the animations for all nodes of a `Model`.
class ModelAnimation({
  required final String? name,
  required final Map<int, NodeAnimation> nodes,
  List<AnimationEvent3D> events = const [],
}) {
  /// Timed events sorted in ascending [AnimationEvent3D.time] order.
  final List<AnimationEvent3D> events = _sortEvents(events);

  final double lastTime = _computeLastTime(nodes, events);

  static List<AnimationEvent3D> _sortEvents(List<AnimationEvent3D> source) {
    if (source.isEmpty) {
      return const [];
    }
    final sorted = List<AnimationEvent3D>.of(source)
      ..sort((a, b) => a.time.compareTo(b.time));
    return List<AnimationEvent3D>.unmodifiable(sorted);
  }

  static double _computeLastTime(
    Map<int, NodeAnimation> nodes,
    List<AnimationEvent3D> events,
  ) {
    var best = 0.0;
    for (final node in nodes.values) {
      best = max(best, node.lastTime);
    }
    for (final event in events) {
      best = max(best, event.time);
    }
    return best;
  }
}
