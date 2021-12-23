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
// TRANSLATED INTO DART from original $GDXAI/steer/Limiter.java
// -----------------------------------------------------------------------------
import 'package:meta/meta.dart';

/// A [Limiter] provides the maximum magnitudes of speed and acceleration for
/// both linear and angular components.
@experimental
abstract class Limiter {
  /// The threshold below which the linear speed can be considered zero. It
  /// must be a small positive value near to zero. Usually it is used to avoid
  /// updating the orientation when the velocity vector has a negligible length.
  double get zeroLinearSpeedThreshold;

  /// Maximum linear speed.
  double get maxLinearSpeed;

  /// Maximum linear acceleration.
  double get maxLinearAcceleration;

  /// Maximum angular speed.
  double get maxAngularSpeed;

  /// Maximum angular acceleration.
  double get maxAngularAcceleration;
}
