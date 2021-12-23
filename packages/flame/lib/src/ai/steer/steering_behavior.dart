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
// $GDX/ai/steer/SteeringBehavior.java
// -----------------------------------------------------------------------------

import 'package:meta/meta.dart';

import 'limiter.dart';
import 'steerable.dart';
import 'steering_acceleration.dart';

/// A [SteeringBehavior] calculates the linear and/or angular accelerations to
/// be applied to its owner.
abstract class SteeringBehavior {
  /// A flag indicating whether this steering behavior is enabled or not.
  bool enabled = true;

  /// The owner of this steering behavior. The owner must be set by the user
  /// prior to using this class.
  late Steerable owner;

  /// The limiter of this steering behavior
  Limiter? limiter;

  /// The actual limiter of this steering behavior
  Limiter get actualLimiter => limiter ?? owner;

  /// If this behavior is enabled, calculates the steering acceleration and
  /// writes it into the given [steering] output. If it is disabled, the
  /// [steering] output is set to zero.
  void calculateSteering(double dt, SteeringAcceleration steering) {
    if (enabled) {
      calculateRealSteering(dt, steering);
    } else {
      steering.setZero();
    }
  }

  /// Calculates the steering acceleration produced by this behavior and writes
  /// it to the given [steering] output.
  ///
  /// This method must be implemented by the subclasses.
  @protected
  void calculateRealSteering(double dt, SteeringAcceleration steering);
}
