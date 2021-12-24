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
// $GDX/ai/utils/Location.java
// -----------------------------------------------------------------------------
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

/// The [Location] interface represents any game object having a position and
/// an orientation.
abstract class Location {
  /// Vector indicating the position of this location.
  Vector2 get position;

  /// Float value indicating the orientation of this location. The orientation
  /// is the angle in radians representing the direction that this location is
  /// facing.
  double get orientation;

  /// Returns the angle in radians pointing along the specified vector.
  double vectorToAngle(Vector2 vector);

  /// Returns the unit vector in the direction of the specified angle
  /// expressed in radians. This method must be consistent with
  /// `vector2Angle()`.
  Vector2 angleToVector(double angle);
}
