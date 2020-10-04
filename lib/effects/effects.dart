import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../components/position_component.dart';
import '../extensions/vector2.dart';

export './move_effect.dart';
export './rotate_effect.dart';
export './scale_effect.dart';
export './sequence_effect.dart';

abstract class PositionComponentEffect {
  PositionComponent component;
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
  double travelTime;
  double currentTime = 0.0;
  double driftTime = 0.0;
  int curveDirection = 1;

  /// Used to be able to determine the start state of the component
  Vector2 originalPosition;
  double originalAngle;
  Vector2 originalSize;

  /// Used to be able to determine the end state of a sequence of effects
  Vector2 endPosition;
  double endAngle;
  Vector2 endSize;

  /// If the effect is alternating the travel time is double the normal
  /// travel time
  double get totalTravelTime => travelTime * (isAlternating ? 2 : 1);

  PositionComponentEffect(
    this._initialIsInfinite,
    this._initialIsAlternating, {
    this.isRelative = false,
    this.onComplete,
  }) {
    isInfinite = _initialIsInfinite;
    isAlternating = _initialIsAlternating;
  }

  void update(double dt) {
    _updateDriftTime();
    if (isAlternating) {
      curveDirection = isMax() ? -1 : (isMin() ? 1 : curveDirection);
    } else if (isInfinite && isMax()) {
      currentTime = 0.0;
    }
    final driftMultiplier = (isAlternating && isMax() ? 2 : 1) * curveDirection;
    if (!hasFinished()) {
      currentTime += dt * curveDirection + driftTime * driftMultiplier;
      percentage = min(1.0, max(0.0, currentTime / travelTime));
      if (hasFinished()) {
        onComplete?.call();
      }
    }
  }

  @mustCallSuper
  void initialize(PositionComponent _comp) {
    component = _comp;
    originalPosition = component.position;
    originalAngle = component.angle;
    originalSize = component.size;

    /// You need to set the travelTime during the initialization of the
    /// extending effect
    travelTime = null;

    /// If these aren't modified by the extending effect it is assumed that the
    /// effect didn't bring the component to another state than the one it
    /// started in
    endPosition = _comp.position;
    endAngle = _comp.angle;
    endSize = _comp.size;
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
