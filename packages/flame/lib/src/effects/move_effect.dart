import 'dart:ui';

import 'package:flutter/animation.dart';

import '../../components.dart';
import '../extensions/vector2.dart';
import 'effects.dart';

class Vector2Percentage {
  final Vector2 v;
  final Vector2 previous;
  final double startAt;
  final double endAt;

  Vector2Percentage(
    this.v,
    this.previous,
    this.startAt,
    this.endAt,
  );
}

class MoveEffect extends SimplePositionComponentEffect {
  List<Vector2> path;
  Vector2Percentage? _currentSubPath;
  List<Vector2Percentage>? _percentagePath;
  late Vector2 _startPosition;

  /// Duration or speed needs to be defined
  MoveEffect({
    required this.path,
    double? duration,
    double? speed,
    Curve? curve,
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    VoidCallback? onComplete,
  })  : assert(
          (duration != null) ^ (speed != null),
          'Either speed or duration necessary',
        ),
        super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          modifiesPosition: true,
          onComplete: onComplete,
        );

  @override
  void initialize(PositionComponent component) {
    super.initialize(component);
    List<Vector2> _movePath;
    _startPosition = component.position.clone();
    // With relative here we mean that any vector in the list is relative
    // to the previous vector in the list, except the first one which is
    // relative to the start position of the component.
    if (isRelative) {
      var lastPosition = _startPosition;
      _movePath = [];
      for (final v in path) {
        final nextPosition = v + lastPosition;
        _movePath.add(nextPosition);
        lastPosition = nextPosition;
      }
    } else {
      _movePath = path;
    }
    endPosition = isAlternating ? _startPosition : _movePath.last;

    var pathLength = 0.0;
    var lastPosition = _startPosition;
    for (final v in _movePath) {
      pathLength += v.distanceTo(lastPosition);
      lastPosition = v;
    }

    _percentagePath = <Vector2Percentage>[];
    lastPosition = _startPosition;
    for (final v in _movePath) {
      final lengthToPrevious = lastPosition.distanceTo(v);
      final lastEndAt =
          _percentagePath!.isNotEmpty ? _percentagePath!.last.endAt : 0.0;
      final endPercentage = lastEndAt + lengthToPrevious / pathLength;
      _percentagePath!.add(
        Vector2Percentage(
          v,
          lastPosition,
          lastEndAt,
          _movePath.last == v ? 1.0 : endPercentage,
        ),
      );
      lastPosition = v;
    }
    final totalPathLength = isAlternating ? pathLength * 2 : pathLength;
    speed ??= totalPathLength / duration!;

    // `duration` is not null when speed is null
    duration ??= totalPathLength / speed!;

    // `speed` is always not null here already
    peakTime = isAlternating ? duration! / 2 : duration!;
  }

  @override
  void reset() {
    super.reset();
    if (_percentagePath?.isNotEmpty ?? false) {
      _currentSubPath = _percentagePath!.first;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _currentSubPath ??= _percentagePath!.first;
    if (!curveDirection.isNegative && _currentSubPath!.endAt < curveProgress ||
        curveDirection.isNegative && _currentSubPath!.startAt > curveProgress) {
      _currentSubPath =
          _percentagePath!.firstWhere((v) => v.endAt >= curveProgress);
    }
    final lastEndAt = _currentSubPath!.startAt;
    final localPercentage =
        (curveProgress - lastEndAt) / (_currentSubPath!.endAt - lastEndAt);
    component?.position.setFrom(_currentSubPath!.previous +
        ((_currentSubPath!.v - _currentSubPath!.previous) * localPercentage));
  }
}
