import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import 'controllers/effect_controller.dart';
import 'transform2d_effect.dart';

/// This effect will move the target along the specified path, which may
/// contain curved segments, but must be simply-connected.
///
/// If `absolute` is false (default), the `path` argument will be taken as
/// relative to the target's position at the start of the effect. It is
/// recommended in this case to have a path that starts at the origin in order
/// to avoid sudden jumps in the target's position.
///
/// If `absolute` flag is true, then the `path` will be assumed to be given in
/// absolute coordinate space and the target will be placed at the beginning of
/// the path when the effect starts.
class MoveAlongPathEffect extends Transform2DEffect {
  MoveAlongPathEffect(
    Path path,
    EffectController controller, {
    bool absolute = false,
  })  : _isAbsolute = absolute,
        super(controller) {
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

  /// If true, the path is considered _absolute_, i.e. the component will be
  /// put onto the start of the path and then follow that path. If false, the
  /// path is considered _relative_, i.e. this path is added as an offset to
  /// the current position of the target.
  final bool _isAbsolute;

  /// The path that the target will follow.
  late final PathMetric _pathMetric;

  /// Pre-computed length of the path.
  late final double _pathLength;

  /// Position offset that was applied to the target on the previous iteration.
  /// This is needed in order to make updates to `target.position` incremental
  /// (which in turn is necessary in order to allow multiple effects to be able
  /// to apply to the same target simultaneously).
  late Vector2 _lastOffset;

  @override
  void onStart() {
    if (_isAbsolute) {
      final pathStart = _pathMetric.getTangentForOffset(0)!.position;
      target.position.x = pathStart.dx;
      target.position.y = pathStart.dy;
      _lastOffset = Vector2(pathStart.dx, pathStart.dy);
    } else {
      _lastOffset = Vector2.zero();
    }
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
