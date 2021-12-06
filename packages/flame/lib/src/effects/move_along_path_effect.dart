import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import 'controllers/effect_controller.dart';
import 'transform2d_effect.dart';

/// This effect will move the target along the specified path, which may
/// contain curved segments, but must be simply-connected. The `path` argument
/// is taken as relative to the target's position at the start of the effect.
class MoveAlongPathEffect extends Transform2DEffect {
  MoveAlongPathEffect(Path path, EffectController controller)
      : super(controller) {
    final metrics = path.computeMetrics().toList();
    if (metrics.length != 1) {
      throw ArgumentError(
        'Only single-contour paths are allowed in MoveAlongPathEffect',
      );
    }
    _pathMetric = metrics[0];
    _pathLength = _pathMetric.length;
    assert(_pathLength > 0);
  }

  late final PathMetric _pathMetric;
  late final double _pathLength;
  late Vector2 _lastOffset;

  @override
  void onStart() {
    _lastOffset = Vector2.zero();
  }

  @override
  void apply(double progress) {
    final distance = progress * _pathLength;
    final tangent = _pathMetric.getTangentForOffset(distance)!;
    final offset = tangent.position;
    target.position.x += offset.dx - _lastOffset.x;
    target.position.y += offset.dy - _lastOffset.y;
    _lastOffset.x = offset.dx;
    _lastOffset.y = offset.dy;
    super.apply(progress);
  }
}
