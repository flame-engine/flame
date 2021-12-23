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
// $GDX/ai/steer/Steerable.java
// -----------------------------------------------------------------------------

import 'package:vector_math/vector_math_64.dart';

import '../utils/location.dart';
import 'limiter.dart';

/// A [Steerable] is a [Location] that gives access to the character's data
/// required by steering system.
///
/// Notice that there is nothing to connect the direction that a Steerable is
/// moving and the direction it is facing. For instance, a character can be
/// oriented along the x-axis but be traveling directly along the y-axis.
abstract class Steerable extends Location with Limiter {
  /// The vector indicating the linear velocity of this Steerable.
  Vector2 get linearVelocity;

  /// The angular velocity in radians of this Steerable.
  double get angularSpeed;

  /// The bounding radius of this Steerable.
  double get boundingRadius;

  /// Generic flag utilized in a variety of ways.
  bool tagged = false;
}
