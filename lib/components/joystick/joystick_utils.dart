import 'dart:ui';

import '../../sprite.dart';
import '../../extensions/offset.dart';
import '../../extensions/size.dart';

class JoystickUtils {
  static void renderControl(Canvas c, Sprite sprite, Rect rect, Paint paint) {
    if (rect == null) {
      return;
    }

    if (sprite == null) {
      final double radius = rect.width / 2;
      c.drawCircle(
        Offset(rect.left + radius, rect.top + radius),
        radius,
        paint,
      );
    } else {
      sprite.render(
        c,
        position: rect.topLeft.toVector2(),
        size: rect.size.toVector2(),
      );
    }
  }
}
