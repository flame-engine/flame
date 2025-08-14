import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';

class PointerEventsGame extends FlameGame with TapCallbacks {
  @override
  Future<void> onLoad() async {
    add(HoverTarget(Vector2(100, 200)));
    add(HoverTarget(Vector2(300, 300)));
    add(HoverTarget(Vector2(400, 50)));
  }

  @override
  void onTapDown(TapDownEvent event) {
    add(HoverTarget(event.localPosition));
  }
}

class HoverTarget extends PositionComponent with HoverCallbacks {
  static final Random _random = Random();

  HoverTarget(Vector2 position)
    : super(
        position: position,
        size: Vector2.all(50),
        anchor: Anchor.center,
      );

  final _paint = Paint()
    ..color = HSLColor.fromAHSL(
      1,
      _random.nextDouble() * 360,
      1,
      0.8,
    ).toColor().withValues(alpha: 0.5);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void onHoverEnter() {
    _paint.color = _paint.color.withValues(alpha: 1);
  }

  @override
  void onHoverExit() {
    _paint.color = _paint.color.withValues(alpha: 0.5);
  }
}
