import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import 'effect_controller.dart';
import 'transform2d_effect.dart';

/// Move a component to a new position.
///
/// The following constructors are provided:
///
///   - [MoveEffect.by] will move the target in a straight line to a new
///     position that is at an `offset` from the target's position at the onset
///     of the effect;
///
///   - [MoveEffect.to] will move the target in a straight line to the specified
///     coordinates;
///
///   - [MoveEffect.along] will move the target along the specified path, which
///     may contain curved segments, but must be simply-connected. The `path`
///     argument is taken as relative to the target's position at the start of
///     the effect.
///
/// This effect applies incremental changes to the component's position, and
/// requires that any other effect or update logic applied to the same component
/// also used incremental updates.
class MoveEffect extends Transform2DEffect {
  MoveEffect.by(Vector2 offset, EffectController controller)
      : _offset = offset.clone(),
        super(controller);

  factory MoveEffect.to(Vector2 destination, EffectController controller) =>
      _MoveToEffect(destination, controller);

  factory MoveEffect.along(Path path, EffectController controller) =>
      _MoveAlongPathEffect(path, controller);

  Vector2 _offset;

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.position += _offset * dProgress;
    super.apply(progress);
  }
}

/// Implementation class for [MoveEffect.to]
class _MoveToEffect extends MoveEffect {
  _MoveToEffect(Vector2 destination, EffectController controller)
      : _destination = destination.clone(),
        super.by(Vector2.zero(), controller);

  final Vector2 _destination;

  @override
  void onStart() {
    _offset = _destination - target.position;
  }
}

/// Implementation class for [MoveEffect.along].
class _MoveAlongPathEffect extends MoveEffect {
  _MoveAlongPathEffect(Path path, EffectController controller)
      : _lastPosition = Vector2.zero(),
        super.by(Vector2.zero(), controller) {
    final metrics = path.computeMetrics().toList();
    if (metrics.length != 1) {
      throw ArgumentError(
        'Only single-contour paths are allowed in MoveEffect.along',
      );
    }
    _pathMetric = metrics[0];
    _pathLength = _pathMetric.length;
    assert(_pathLength > 0);
  }

  late final PathMetric _pathMetric;
  late final double _pathLength;
  late Vector2 _lastPosition;

  @override
  void apply(double progress) {
    final distance = progress * _pathLength;
    final tangent = _pathMetric.getTangentForOffset(distance)!;
    final offset = tangent.position;
    target.position.x += offset.dx - _lastPosition.x;
    target.position.y += offset.dy - _lastPosition.y;
    _lastPosition.setValues(offset.dx, offset.dy);
    super.apply(progress);
  }

  @override
  void reset() {
    super.reset();
    _lastPosition = Vector2.zero();
  }
}
