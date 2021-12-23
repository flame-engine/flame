// Copyright 2021 Blue Fire team, MIT license
//
// -- Original license notice: -------------------------------------------------
// Copyright 2014 See AUTHORS file.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------
// TRANSLATED INTO DART from original $GDXAI/steer/behaviors/Pursue.java
// -----------------------------------------------------------------------------
import 'dart:math' as math;
import 'package:meta/meta.dart';

import '../../../extensions/vector2.dart';
import '../steerable.dart';
import '../steering_acceleration.dart';
import '../steering_behavior.dart';

/// [Pursue] behavior produces a force that steers the agent towards the evader
/// (the target).
///
/// Actually it predicts where an agent will be in time `t` and seeks towards
/// that point to intercept it. We did this naturally playing tag as children,
/// which is why the most difficult tag players to catch were those who kept
/// switching direction, foiling our predictions.
///
/// This implementation performs the prediction by assuming the target will
/// continue moving with the same velocity it currently has. This is a
/// reasonable assumption over short distances, and even over longer distances
/// it doesn't appear too stupid. The algorithm works out the distance between
/// the character and the target and works out how long it would take to get
/// there, at maximum speed. It uses this time interval as its prediction
/// lookahead. It calculates the position of the target if it continues to move
/// with its current velocity. This new position is then used as the target of
/// a standard seek behavior.
///
/// If the character is moving slowly, or the target is a long way away, the
/// prediction time could be very large. The target is less likely to follow
/// the same path forever, so we'd like to set a limit on how far ahead we aim.
/// The algorithm has a [maxPredictionTime] for this reason. If the prediction
/// time is beyond this, then the maximum time is used.
class Pursue extends SteeringBehavior {
  Pursue({
    required Steerable owner,
    required this.target,
    this.maxPredictionTime = 1.0,
  }) : super(owner);

  Steerable target;

  final double maxPredictionTime;

  @override
  @protected
  void calculateRealSteering(SteeringAcceleration steering) {
    final targetPosition = target.position;
    // Square distance to the evader (the target)
    final squareDistance = (targetPosition - owner.position).length2;
    // Our current square speed
    final squareSpeed = owner.linearVelocity.length2;

    var predictionTime = maxPredictionTime;
    if (squareSpeed > 0) {
      // Calculate prediction time if speed is not too small to give a
      // reasonable value
      final squarePredictionTime = squareDistance / squareSpeed;
      if (squarePredictionTime < maxPredictionTime * maxPredictionTime) {
        predictionTime = math.sqrt(squarePredictionTime);
      }
    }

    // Calculate and seek/flee the predicted position of the target
    steering.linear
      ..setFrom(targetPosition)
      ..mulAdd(target.linearVelocity, predictionTime)
      ..sub(owner.position)
      ..length = actualMaxLinearAcceleration;
    // No angular acceleration
    steering.angular = 0;
  }

  /// Returns the actual linear acceleration to be applied. This method is
  /// overridden by the `Evade` behavior to invert the maximum linear
  /// acceleration in order to evade the target.
  @protected
  double get actualMaxLinearAcceleration {
    return actualLimiter.maxLinearAcceleration;
  }
}
