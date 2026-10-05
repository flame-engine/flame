import 'package:flame/extensions.dart';
import 'package:meta/meta.dart';

/// The signed area of the [polygon], which is positive when its vertices go
/// clockwise in the screen coordinate system, where the y axis points down,
/// and negative when they go counterclockwise.
@internal
double signedArea(List<Vector2> polygon) {
  var area = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final a = polygon[i];
    final b = polygon[(i + 1) % polygon.length];
    area += a.x * b.y - b.x * a.y;
  }
  return area / 2;
}
