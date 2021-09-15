import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

class LogoCompomnent extends SpriteComponent with HasGameRef<DebugGame> {
  static const int speed = 150;

  int xDirection = 1;
  int yDirection = 1;

  LogoCompomnent(Sprite sprite) : super(sprite: sprite, size: sprite.srcSize);

  @override
  void update(double dt) {
    super.update(dt);

    x += xDirection * speed * dt;

    final rect = toRect();

    if ((x <= 0 && xDirection == -1) ||
        (rect.right >= gameRef.size.x && xDirection == 1)) {
      xDirection = xDirection * -1;
    }

    y += yDirection * speed * dt;

    if ((y <= 0 && yDirection == -1) ||
        (rect.bottom >= gameRef.size.y && yDirection == 1)) {
      yDirection = yDirection * -1;
    }
  }
}

class DebugGame extends FlameGame with FPSCounter {
  static final fpsTextPaint = TextPaint(
    config: const TextPaintConfig(
      color: Color(0xFFFFFFFF),
    ),
  );

  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final flameLogo = await loadSprite('flame.png');

    final flame1 = LogoCompomnent(flameLogo);
    flame1.x = 100;
    flame1.y = 400;

    final flame2 = LogoCompomnent(flameLogo);
    flame2.x = 100;
    flame2.y = 400;
    flame2.yDirection = -1;

    final flame3 = LogoCompomnent(flameLogo);
    flame3.x = 100;
    flame3.y = 400;
    flame3.xDirection = -1;

    add(flame1);
    add(flame2);
    add(flame3);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (debugMode) {
      fpsTextPaint.render(canvas, fps(120).toString(), Vector2(0, 50));
    }
  }
}
