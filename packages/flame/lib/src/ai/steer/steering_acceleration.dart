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
// TRANSLATED INTO DART from original $GDXAI/steer/SteeringAcceleration.java
// -----------------------------------------------------------------------------

import 'package:vector_math/vector_math_64.dart';

/// [SteeringAcceleration] is a movement requested by the steering system. It
/// is made up of two components, linear and angular acceleration.
class SteeringAcceleration {
  /// Creates a [SteeringAcceleration] with the given [linear] and [angular]
  /// accelerations.
  SteeringAcceleration (this.linear, [this.angular = 0]);

  /// The linear component of this steering acceleration.
  Vector2 linear;

  /// The angular component of this steering acceleration.
  double angular;

  /// Returns true if both linear and angular components of this steering
  /// acceleration are zero, false otherwise.
  bool get isZero => angular == 0 && linear.x == 0 && linear.y == 0;

  /// Sets the linear and angular components of this steering acceleration to
  /// zero.
  void setZero() {
    linear.setZero();
    angular = 0;
  }

  /// Adds the [other] steering acceleration to this steering acceleration.
  void add(SteeringAcceleration other) {
    linear.add(other.linear);
    angular += other.angular;
  }

  /// First apply [scale] to the supplied [steering], then add it to this
  /// steering acceleration.
  void mulAdd (SteeringAcceleration steering, double scale) {
    linear.x += steering.linear.x * scale;
    linear.y += steering.linear.y * scale;
    angular += steering.angular * scale;
  }

  /// Returns the square of the magnitude of this steering acceleration. This
  /// includes the angular component.
  double calculateSquareMagnitude () {
    return linear.length2 + angular * angular;
  }
}
