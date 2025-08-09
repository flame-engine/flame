import 'dart:math';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/parser/gltf/animation_interpolation.dart';

abstract class AnimationSpline<T> {
  final AnimationInterpolation interpolation;
  final List<(double, T)> values;

  AnimationSpline({
    required this.interpolation,
    required this.values,
  });

  AnimationSpline.from({
    required this.interpolation,
    required List<double> times,
    required List<T> values,
  }) : values = List.generate(times.length, (index) {
          return (times[index], values[index]);
        });

  T lerp(T a, T b, double t);
  void transform(Matrix4 matrix, T value);
}

class TranslationAnimationSpline extends AnimationSpline<Vector3> {
  TranslationAnimationSpline.from({
    required super.interpolation,
    required super.times,
    required super.values,
  }) : super.from();

  @override
  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return interpolation.lerp(a, b, t);
  }

  @override
  void transform(Matrix4 matrix, Vector3 value) {
    matrix.setTranslation(value);
  }
}

class ScaleAnimationSpline extends AnimationSpline<Vector3> {
  ScaleAnimationSpline.from({
    required super.interpolation,
    required super.times,
    required super.values,
  }) : super.from();

  @override
  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return interpolation.lerp(a, b, t);
  }

  @override
  void transform(Matrix4 matrix, Vector3 value) {
    matrix.scale(value);
  }
}

class RotationAnimationSpline extends AnimationSpline<Quaternion> {
  RotationAnimationSpline.from({
    required super.interpolation,
    required super.times,
    required super.values,
  }) : super.from();

  @override
  Quaternion lerp(Quaternion a, Quaternion b, double t) {
    return interpolation.slerp(a, b, t);
  }

  @override
  void transform(Matrix4 matrix, Quaternion value) {
    matrix.setRotation(value.asRotationMatrix());
  }
}

class AnimationController<T> {
  final AnimationSpline<T> animation;
  final double lastTime;

  AnimationController({
    required this.animation,
  }) : lastTime = animation.values.last.$1;

  T sample(double time) {
    final values = animation.values;

    if (time < values.first.$1) {
      return values.first.$2;
    }

    if (time > values.last.$1) {
      return values.last.$2;
    }

    for (var i = 0; i < values.length - 1; i++) {
      final t0 = values[i].$1;
      final t1 = values[i + 1].$1;

      if (time >= t0 && time < t1) {
        final t = (time - t0) / (t1 - t0);
        final value0 = values[i].$2;
        final value1 = values[i + 1].$2;
        return animation.lerp(value0, value1, t);
      }
    }

    throw Exception('This should never happen');
  }

  void sampleInto(double time, Matrix4 matrix) {
    final value = sample(time);
    animation.transform(matrix, value);
  }
}

class NodeAnimation {
  final List<AnimationController> channels;
  final double lastTime;

  NodeAnimation({
    required this.channels,
  }) : lastTime = channels.map((e) => e.lastTime).reduce(max);

  void sampleInto(double time, Matrix4 matrix) {
    for (final channel in channels) {
      channel.sampleInto(time, matrix);
    }
  }
}

class ModelAnimation {
  final String? name;
  final Map<int, NodeAnimation> nodes;
  final double lastTime;

  ModelAnimation({
    required this.name,
    required this.nodes,
  }) : lastTime = nodes.values.map((e) => e.lastTime).reduce(max);
}
