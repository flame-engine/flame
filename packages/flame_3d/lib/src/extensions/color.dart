import 'dart:typed_data';
import 'dart:ui';

extension ColorExtension on Color {
  /// Returns a Float32List that represents the color as a vector.
  Float32List get storage => Float32List.fromList([
    a,
    r,
    g,
    b,
  ]);
}
