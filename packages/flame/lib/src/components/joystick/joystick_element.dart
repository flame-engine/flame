import 'dart:ui';

import '../../../components.dart';
import '../../../extensions.dart';

/// This is an element drawn on the canvas on the position [rect];
///
/// It can be either a [sprite] or a [paint] (solid color circle). Not both.
class JoystickElement {
  final Sprite? sprite;
  final Paint? paint;

  late Rect rect;

  JoystickElement.sprite(this.sprite) : paint = null;

  JoystickElement.paint(this.paint) : sprite = null;

  Vector2 get center => rect.center.toVector2();

  void shift(Vector2 diff) {
    rect = rect.shift(diff.toOffset());
  }

  void render(Canvas c) {
    final rect = this.rect;
    final sprite = this.sprite;
    final paint = this.paint;

    if (sprite == null) {
      assert(paint != null, '`paint` must not be `null` if `sprite` is `null`');

      final radius = rect.width / 2;
      c.drawCircle(rect.center, radius, paint!);
    } else {
      sprite.render(
        c,
        position: rect.topLeft.toVector2(),
        size: rect.size.toVector2(),
      );
    }
  }
}
