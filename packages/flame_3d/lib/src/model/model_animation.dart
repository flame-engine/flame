import 'dart:math';

// TODO(spydon): Remove this import once Flutter 3.35.0 is the minimum version.
// ignore: unnecessary_import
import 'package:flame/extensions.dart';
// ignore: unnecessary_import
import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';
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

  AnimationSpline({
    required this.interpolation,
    required this.values,
  });

  AnimationSpline.from({
    required this.interpolation,
    required List<double> times,
    required List<T> values,
  }) : values = List.generate(times.length, (index) {
         return (time: times[index], value: values[index]);
       });

  T lerp(T a, T b, double t);
  void transform(Matrix4 matrix, T value);
}

/// An animation spline over the position of a transformation (translation).
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

/// An animation spline over the angle of a transformation (rotation).
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

/// An animation spline over the scale of a transformation (scaling).
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
    matrix.scaleByVector3(value);
  }
}

/// Allows sampling of an animation by interpolating keyframes.
class AnimationController<T> {
  final AnimationSpline<T> animation;
  final double lastTime;

  AnimationController({
    required this.animation,
  }) : lastTime = animation.values.last.time;

  T sample(double time) {
    final values = animation.values;

    if (time < values.first.time) {
      return values.first.value;
    }

    if (time > values.last.time) {
      return values.last.value;
    }

    for (var i = 0; i < values.length - 1; i++) {
      final t0 = values[i].time;
      final t1 = values[i + 1].time;

      if (time >= t0 && time < t1) {
        final t = (time - t0) / (t1 - t0);
        final value0 = values[i].value;
        final value1 = values[i + 1].value;
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

/// Groups the animations of a single node in a [Model], which can be
/// controlled by multiple animation channels.
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

/// Groups the animations for all nodes of a [Model].
class ModelAnimation {
  final String? name;
  final Map<int, NodeAnimation> nodes;
  final double lastTime;

  ModelAnimation({
    required this.name,
    required this.nodes,
  }) : lastTime = nodes.values.map((e) => e.lastTime).reduce(max);
}
