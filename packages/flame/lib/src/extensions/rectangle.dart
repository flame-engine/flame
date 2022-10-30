import 'dart:math' show Rectangle;
import 'dart:ui' show Rect;

extension RectangleExtension on Rectangle {
  /// Converts this math [Rectangle] into an ui [Rect].
  Rect toRect() {
    return Rect.fromLTWH(
      left.toDouble(),
      top.toDouble(),
      width.toDouble(),
      height.toDouble(),
    );
  }
}
