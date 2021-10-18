import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import 'flame_animation_controller.dart';
import 'transform2d_effect.dart';

/// Move a component to the `destination` point along a straight line.
///
/// This effect applies incremental changes to the component's coordinates, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class MoveToEffect extends Transform2DEffect {
  MoveToEffect({
    required Vector2 destination,
    required FlameAnimationController controller,
  })  : _destination = destination.clone(),
        _lastProgress = 0,
        super(controller: controller);

  final Vector2 _destination;
  late final Vector2 _offset;
  double _lastProgress;

  @override
  void onStart() {
    _offset = _destination - target.position;
  }

  @override
  void apply(double progress) {
    final dProgress = progress - _lastProgress;
    target.position += _offset * dProgress;
    _lastProgress = progress;
  }

  @override
  void reset() {
    super.reset();
    _lastProgress = 0;
  }
}


/// Move a component to a new point that is at an `offset` from the component's
/// position at the onset of the effect.
///
/// This effect applies incremental changes to the component's coordinates, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class MoveByEffect extends Transform2DEffect {
  MoveByEffect({
    required Vector2 offset,
    required FlameAnimationController controller,
  })  : _offset = offset.clone(),
        _lastProgress = 0,
        super(controller: controller);

  final Vector2 _offset;
  double _lastProgress;

  @override
  void apply(double progress) {
    final dProgress = progress - _lastProgress;
    target.position += _offset * dProgress;
    _lastProgress = progress;
  }

  @override
  void reset() {
    super.reset();
    _lastProgress = 0;
  }
}


/// Move a component along the specified `path`. The path may contain curved
/// segments, but must be single-component, i.e. it should be simply connected.
///
/// This effect applies incremental changes to the component's coordinates, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class MoveAlongPathEffect extends Transform2DEffect {
  MoveAlongPathEffect({
    required Path path,
    required FlameAnimationController controller,
  })  : _lastPosition = Vector2.zero(),
        super(controller: controller) {
    final metrics = path.computeMetrics().toList();
    if (metrics.length != 1) {
      throw ArgumentError(
        'Only single-contour paths are allowed in MoveAlongPathEffect',
      );
    }
    _pathMetric = metrics[0];
    _pathLength = _pathMetric.length;
  }

  late final PathMetric _pathMetric;
  late final double _pathLength;
  Vector2 _lastPosition;

  @override
  void apply(double progress) {
    final distance = progress * _pathLength;
    final tangent = _pathMetric.getTangentForOffset(distance);
    if (tangent != null) {
      final offset = tangent.position;
      final newPosition = Vector2(offset.dx, offset.dy);
      target.position += newPosition - _lastPosition;
      _lastPosition = newPosition;
    }
  }

  @override
  void reset() {
    super.reset();
    _lastPosition = Vector2.zero();
  }
}
