import 'package:flame/components.dart';

enum LayoutComponentExampleSize {
  shrinkWrap(null, null),
  small(640, 480),
  large(1080, 720)
  ;

  const LayoutComponentExampleSize(
    this.x,
    this.y,
  );
  final double? x;
  final double? y;

  Vector2? toVector2() {
    final x = this.x;
    final y = this.y;
    if (x == null || y == null) {
      return null;
    } else {
      return Vector2(x, y);
    }
  }
}
