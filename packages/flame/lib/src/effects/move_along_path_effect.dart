import 'dart:ui';

import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/move_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:vector_math/vector_math_64.dart';

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
///
/// The `oriented` flag controls the direction of the target as it follows the
/// path. If this flag is false (default), the target keeps its original
/// orientation. If the flag is true, the target is automatically rotated as it
/// follows the path so that it is always oriented tangent to the path. When
/// using this flag, make sure that the effect is applied to a target that
/// actually supports rotations.
class MoveAlongPathEffect extends MoveEffect {
  MoveAlongPathEffect(
    Path path,
    EffectController controller, {
    bool absolute = false,
    bool oriented = false,
    PositionProvider? target,
  })  : _isAbsolute = absolute,
        _followDirection = oriented,
        super(controller, target) {
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

  /// If true, then not only the target's position will follow the path, but
  /// also the target's angle of rotation.
  final bool _followDirection;

  /// The path that the target will follow.
  late final PathMetric _pathMetric;

  /// Pre-computed length of the path.
  late final double _pathLength;

  /// Position offset that was applied to the target on the previous iteration.
  /// This is needed in order to make updates to `target.position` incremental
  /// (which in turn is necessary in order to allow multiple effects to be able
  /// to apply to the same target simultaneously).
  late Vector2 _lastOffset;

  /// Target's angle of rotation on the previous iteration.
  late double _lastAngle;

  @override
  void onStart() {
    _lastOffset = Vector2.zero();
    _lastAngle = 0;
    if (_followDirection) {
      assert(
        target is AngleProvider,
        'An `oriented` MoveAlongPathEffect cannot be applied to a target that '
        'does not support rotation',
      );
    }
    if (_isAbsolute) {
      final start = _pathMetric.getTangentForOffset(0)!;
      target.position.x = _lastOffset.x = start.position.dx;
      target.position.y = _lastOffset.y = start.position.dy;
      if (_followDirection) {
        (target as AngleProvider).angle = _lastAngle = -start.angle;
      }
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
    if (_followDirection) {
      (target as AngleProvider).angle += -tangent.angle - _lastAngle;
      _lastAngle = -tangent.angle;
    }
  }

  @override
  double measure() => _pathLength;
}
