class FlameAnimationController {
  FlameAnimationController({
    required double duration,
    bool? infinite,
    bool? alternating,
    int? repeatCount,
    double? delay,
  })  : assert(infinite == true ? repeatCount == null : true,
            'An infinite animation cannot have a repeat count'),
        isInfinite = infinite ?? false,
        isAlternating = alternating ?? false,
        repeatCount = repeatCount ?? 1,
        onsetDelay = delay ?? 0.0,
        forwardDuration = duration,
        backwardDuration = duration,
        remainAtPeakDuration = 0.0,
        remainAtPitDuration = 0.0,
        _remainingTimeAtStage = 0.0 {
    _remainingTimeAtStage = onsetDelay;
    _onUpdate = updateBeforeStart;
  }

  /// If the effect should first follow the initial curve and then follow the
  /// curve backwards.
  final bool isAlternating;

  /// Whether the effect should continue to loop forever.
  final bool isInfinite;

  int repeatCount;

  /// The time (in seconds) before the animation begins.
  final double onsetDelay;

  final double forwardDuration;
  final double backwardDuration;
  final double remainAtPeakDuration;
  final double remainAtPitDuration;

  double get cycleDuration {
    return forwardDuration +
        remainAtPeakDuration +
        backwardDuration +
        remainAtPitDuration;
  }

  late double Function(double) _onUpdate;
  double _remainingTimeAtStage;

  void update(double dt) {
    var remainingTime = dt;
    while (remainingTime > 0) {
      remainingTime = _onUpdate(remainingTime);
    }
  }

  double updateBeforeStart(double dt) {
    if (dt > _remainingTimeAtStage) {
      _remainingTimeAtStage -= dt;
      return 0;
    } else {
      final t = dt - _remainingTimeAtStage;
      _onUpdate = updateForward;
      _remainingTimeAtStage = forwardDuration;
      return t;
    }
  }

  double updateForward(double dt) {
    return dt;
  }
}

enum FlameAnimationStage {
  beforeStart,
  forward,
  atPeak,
  backward,
  atPit,
}
