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
// TRANSLATED INTO DART WITH MODIFICATIONS from
// $GDX/ai/steer/behaviors/Pursue.java
// (logic significantly altered from the original)
// -----------------------------------------------------------------------------
import 'dart:math' as math;

import '../steerable.dart';
import '../steering_acceleration.dart';
import '../steering_behavior.dart';

/// [Pursue] behavior produces a force that steers the agent towards the target.
///
/// Actually it predicts where the target will be in the near future, and seeks
/// towards that point to intercept it. The "near future" here means the amount
/// of time it would take for the pursuer to reach the target at the current
/// speed, but no more than [maxPredictionTime].
///
/// After we determine the point where the target is moving towards, we set as
/// our goal to move to that point at maximum speed. Then, we apply the steering
/// force in such a way as to achieve the desired velocity given the current
/// velocity. The force applied is equal to `maxLinearAcceleration`, unless
/// current speed is sufficiently close to the target speed. This prevents
/// random jerking behavior when the pursuer is already moving at max speed.
///
/// Overall, this behavior aims to intercept the target at the maximum possible
/// speed.
class Pursue extends SteeringBehavior {
  Pursue({Steerable? target, this.maxPredictionTime = 1.0}) {
    this.target = target;
  }

  /// The target that is being pursued. This property can only be accessed if
  /// the target exists (check with [hasTarget]). The behavior is automatically
  /// disabled if there is no target, and re-enabled when the target is
  /// acquired.
  Steerable get target => _target!;
  bool get hasTarget => _target != null;
  Steerable? _target;

  set target(Steerable? value) {
    _target = value;
    enabled = _target != null;
  }

  /// Maximum prediction horizon (in seconds). The pursuer ([owner]) will try
  /// to guess the [target]'s position this far into the future, and will aim
  /// to intercept the target at that point.
  final double maxPredictionTime;

  @override
  void calculateRealSteering(double dt, SteeringAcceleration steering) {
    final vectorToTarget = target.position - owner.position;
    final squareDistanceToTarget = vectorToTarget.length2;
    final currentSquareSpeedDelta =
        (target.linearVelocity - owner.linearVelocity).length2;

    var predictionTime = maxPredictionTime;
    if (currentSquareSpeedDelta > 0) {
      // Calculate prediction time if speed is not too small to give a
      // reasonable value
      final squarePredictionTime =
          squareDistanceToTarget / currentSquareSpeedDelta;
      if (squarePredictionTime < maxPredictionTime * maxPredictionTime) {
        predictionTime = math.sqrt(squarePredictionTime);
      }
    }

    // Calculate and seek/flee the predicted position of the target
    final targetDeltaVelocity = vectorToTarget
      ..addScaled(target.linearVelocity, predictionTime)
      ..length = actualLimiter.maxLinearSpeed
      ..sub(owner.linearVelocity);
    steering.linearAcceleration
      ..setFrom(targetDeltaVelocity)
      ..length = math.min(
        actualLimiter.maxLinearAcceleration,
        targetDeltaVelocity.length / dt,
      );

    // No angular acceleration
    steering.angularAcceleration = 0;
  }
}
