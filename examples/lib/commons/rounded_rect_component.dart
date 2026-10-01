import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:material_ui/material_ui.dart';

/// A rectangle whose corners are rounded with half of its height, so that
/// its short sides are semicircles.
class RoundedRectComponent extends PositionComponent with HasPaint {
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), Radius.circular(height / 2)),
      paint,
    );
  }
}
