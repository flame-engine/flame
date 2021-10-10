
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../../components.dart';
import 'flame_animation_controller.dart';
import 'transform2d_effect.dart';

class MoveAlongPathEffect extends Transform2DEffect {
  MoveAlongPathEffect({
    required Path path,
    required FlameAnimationController controller,
  }) : _lastPosition = Vector2.zero(),
        super(controller: controller) {
    final metrics = path.computeMetrics().toList();
    if (metrics.length != 1) {
      throw ArgumentError(
          'Only single-contour paths are allowed in MoveAlongPathEffect');
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
      final newPosition = Vector2Extension.fromOffset(tangent.position);
      target.position += newPosition - _lastPosition;
      _lastPosition = newPosition;
    }
  }
}