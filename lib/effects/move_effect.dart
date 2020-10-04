import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

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

class MoveEffect extends PositionComponentEffect {
  List<Vector2> path;
  Vector2Percentage _currentSubPath;
  List<Vector2Percentage> _percentagePath;
  double speed;
  Curve curve;
  Vector2 _startPosition;

  MoveEffect({
    @required this.path,
    @required this.speed,
    this.curve,
    isInfinite = false,
    isAlternating = false,
    isRelative = false,
    Function onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          isRelative: isRelative,
          onComplete: onComplete,
        );

  @override
  void initialize(_comp) {
    super.initialize(_comp);
    List<Vector2> _movePath;
    _startPosition = component.position.clone();
    // With relative here we mean that any vector in the list is relative
    // to the previous vector in the list, except the first one which is
    // relative to the start position of the component.
    if (isRelative) {
      Vector2 lastPosition = _startPosition;
      _movePath = [];
      for(Vector2 v in path) {
        final nextPosition = v + lastPosition;
        _movePath.add(nextPosition);
        lastPosition = nextPosition;
      }
    } else {
      _movePath = path;
    }
    if (!isAlternating) {
      endPosition = _movePath.last;
    } else {
      endPosition = _startPosition;
    }

    double pathLength = 0;
    Vector2 lastPosition = _startPosition;
    for (Vector2 v in _movePath) {
      pathLength += v.distanceTo(lastPosition);
      lastPosition = v;
    }

    _percentagePath = <Vector2Percentage>[];
    lastPosition = _startPosition;
    for (Vector2 v in _movePath) {
      final lengthToPrevious = lastPosition.distanceTo(v);
      final lastEndAt =
          _percentagePath.isNotEmpty ? _percentagePath.last.endAt : 0.0;
      final endPercentage = lastEndAt + lengthToPrevious / pathLength;
      _percentagePath.add(
        Vector2Percentage(
          v,
          lastPosition,
          lastEndAt,
          _movePath.last == v ? 1.0 : endPercentage,
        ),
      );
      lastPosition = v;
    }
    travelTime = pathLength / speed;
  }
  
  @override
  void reset() {
    super.reset();
    if(_percentagePath?.isNotEmpty ?? false) {
      _currentSubPath = _percentagePath.first;
    }
  }

  @override
  void update(double dt) {
    if (hasFinished()) {
      return;
    }
    super.update(dt);
    final double progress = curve?.transform(percentage) ?? 1.0;
    _currentSubPath ??= _percentagePath.first;
    if (!curveDirection.isNegative && _currentSubPath.endAt < progress ||
        curveDirection.isNegative && _currentSubPath.startAt > progress) {
      _currentSubPath = _percentagePath.firstWhere((v) => v.endAt >= progress);
    }
    final double lastEndAt = _currentSubPath.startAt;
    final double localPercentage =
        (progress - lastEndAt) / (_currentSubPath.endAt - lastEndAt);
    component.position = _currentSubPath.previous +
        ((_currentSubPath.v - _currentSubPath.previous) *
            localPercentage);
  }
}
