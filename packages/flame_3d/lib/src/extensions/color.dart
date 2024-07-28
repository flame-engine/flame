import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';

extension ColorExtension on Color {
  /// Returns a Float32List that represents the color as a vector.
  Float32List get storage =>
      Float32List.fromList([red / 255, green / 255, blue / 255, opacity]);

  Vector3 toVector3() {
    return Vector3(
      red.toDouble() / 255,
      green.toDouble() / 255,
      blue.toDouble() / 255,
    );
  }
}
