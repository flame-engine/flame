import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';

class DecoratedRectangleComponent extends PositionComponent {
  final Vector2 shadowOffset;
  final Paint shadowPaint;
  final Color backgroundColor;
  final double radius;
  DecoratedRectangleComponent({
    required this.shadowOffset,
    required this.shadowPaint,
    this.backgroundColor = const Color(0xFFeeeeee),
    this.radius = 0,
  }) : super();
  late Paint backgroundPaint;

  @override
  FutureOr<void> onLoad() {
    backgroundPaint = Paint()..color = backgroundColor;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final Rect shadowRect = Rect.fromLTWH(
      shadowOffset.x,
      shadowOffset.y,
      size.x,
      size.y,
    );
    final Rect backgroundRect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        shadowRect,
        Radius.circular(radius), // Adjust corner radius if needed
      ),
      shadowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        backgroundRect,
        Radius.circular(radius), // Adjust corner radius if needed
      ),
      backgroundPaint,
    );
    super.render(canvas);
  }
}
