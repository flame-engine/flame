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
// $GDX/ai/steer/SteeringAcceleration.java
// -----------------------------------------------------------------------------

import '../../extensions/vector2.dart';

/// [SteeringAcceleration] is a movement requested by the steering system. It
/// is made up of two components: linear and angular acceleration.
class SteeringAcceleration {
  SteeringAcceleration({Vector2? linear, double angular = 0})
      : angularAcceleration = angular,
        linearAcceleration = linear ?? Vector2.zero();

  /// The linear component of this steering acceleration.
  Vector2 linearAcceleration;

  /// The angular component of this steering acceleration.
  double angularAcceleration;

  /// Returns true if both linear and angular components of this steering
  /// acceleration are zero, false otherwise.
  bool get isZero => angularAcceleration == 0 && linearAcceleration.isZero();

  /// Sets the linear and angular components of this steering acceleration to
  /// zero.
  void setZero() {
    linearAcceleration.setZero();
    angularAcceleration = 0;
  }

  /// Adds the [other] steering acceleration to this steering acceleration.
  void add(SteeringAcceleration other) {
    linearAcceleration.add(other.linearAcceleration);
    angularAcceleration += other.angularAcceleration;
  }

  /// First apply [scale] to the supplied [steering], then add it to this
  /// steering acceleration.
  void mulAdd(SteeringAcceleration steering, double scale) {
    linearAcceleration.addScaled(steering.linearAcceleration, scale);
    angularAcceleration += steering.angularAcceleration * scale;
  }

  /// Returns the square of the magnitude of this steering acceleration. This
  /// includes the angular component.
  double calculateSquareMagnitude() {
    return linearAcceleration.length2 +
        angularAcceleration * angularAcceleration;
  }
}
