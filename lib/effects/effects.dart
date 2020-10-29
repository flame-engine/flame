import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../components/component.dart';
import '../components/position_component.dart';
import '../extensions/vector2.dart';

export './move_effect.dart';
export './rotate_effect.dart';
export './scale_effect.dart';
export './sequence_effect.dart';

abstract class ComponentEffect<T extends Component> {
  T component;
  Function() onComplete;

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  /// If the animation should first follow the initial curve and then follow the
  /// curve backwards
  bool isInfinite;
  bool isAlternating;
  final bool isRelative;
  final bool _initialIsInfinite;
  final bool _initialIsAlternating;
  double percentage;
  double curveProgress;
  double travelTime;
  double currentTime = 0.0;
  double driftTime = 0.0;
  int curveDirection = 1;
  Curve curve;

  /// If the effect is alternating the travel time is double the normal
  /// travel time
  double get totalTravelTime => travelTime * (isAlternating ? 2 : 1);

  ComponentEffect(
    this._initialIsInfinite,
    this._initialIsAlternating, {
    this.isRelative = false,
    this.curve = Curves.linear,
    this.onComplete,
  }) {
    isInfinite = _initialIsInfinite;
    isAlternating = _initialIsAlternating;
    curve ??= Curves.linear;
  }

  @mustCallSuper
  void update(double dt) {
    if (isAlternating) {
      curveDirection = isMax() ? -1 : (isMin() ? 1 : curveDirection);
    }
    if (isInfinite) {
      if ((!isAlternating && isMax()) || (isAlternating && isMin())) {
        reset();
      }
    }
    if (!hasFinished()) {
      currentTime += (dt + driftTime) * curveDirection;
      percentage = (currentTime / travelTime).clamp(0.0, 1.0).toDouble();
      curveProgress = curve.transform(percentage);
      _updateDriftTime();
      currentTime = currentTime.clamp(0.0, travelTime).toDouble();
      if (hasFinished()) {
        onComplete?.call();
      }
    }
  }

  @mustCallSuper
  void initialize(T component) {
    this.component = component;
  }

  void dispose() => _isDisposed = true;

  bool hasFinished() {
    return (!isInfinite && !isAlternating && isMax()) ||
        (!isInfinite && isAlternating && isMin()) ||
        isDisposed;
  }

  bool isMax() => percentage == null ? false : percentage == 1.0;
  bool isMin() => percentage == null ? false : percentage == 0.0;

  void reset() {
    _isDisposed = false;
    percentage = null;
    currentTime = 0.0;
    curveDirection = 1;
    driftTime = 0.0;
    isInfinite = _initialIsInfinite;
    isAlternating = _initialIsAlternating;
  }

  // When the time overshoots the max and min it needs to add that time to
  // whatever is going to happen next, for example an alternation or
  // following effect in a SequenceEffect.
  void _updateDriftTime() {
    if (isMax()) {
      driftTime = currentTime - travelTime;
    } else if (isMin()) {
      driftTime = currentTime.abs();
    } else {
      driftTime = 0;
    }
  }
}

abstract class PositionComponentEffect
    extends ComponentEffect<PositionComponent> {
  /// Used to be able to determine the start state of the component
  Vector2 originalPosition;
  double originalAngle;
  Vector2 originalSize;

  /// Used to be able to determine the end state of a sequence of effects
  Vector2 endPosition;
  double endAngle;
  Vector2 endSize;

  PositionComponentEffect(
    bool initialIsInfinite,
    bool initialIsAlternating, {
    bool isRelative = false,
    Curve curve,
    void Function() onComplete,
  }) : super(
          initialIsInfinite,
          initialIsAlternating,
          isRelative: isRelative,
          curve: curve,
          onComplete: onComplete,
        );

  @mustCallSuper
  @override
  void initialize(PositionComponent component) {
    super.initialize(component);
    this.component = component;
    originalPosition = component.position;
    originalAngle = component.angle;
    originalSize = component.size;

    /// If these aren't modified by the extending effect it is assumed that the
    /// effect didn't bring the component to another state than the one it
    /// started in
    endPosition = component.position;
    endAngle = component.angle;
    endSize = component.size;
  }
}

abstract class SimplePositionComponentEffect extends PositionComponentEffect {
  double duration;
  double speed;

  SimplePositionComponentEffect(
    bool initialIsInfinite,
    bool initialIsAlternating, {
    this.duration,
    this.speed,
    Curve curve,
    bool isRelative = false,
    void Function() onComplete,
  })  : assert(duration != null || speed != null),
        super(
          initialIsInfinite,
          initialIsAlternating,
          isRelative: isRelative,
          curve: curve,
          onComplete: onComplete,
        );
}
