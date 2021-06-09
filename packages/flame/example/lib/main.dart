import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class Square extends PositionComponent {
  static const speed = 0.25;
  static const squareSize = 128.0;

  static Paint white = BasicPalette.white.paint();
  static Paint red = BasicPalette.red.paint();
  static Paint blue = BasicPalette.blue.paint();

  @override
  void render(Canvas c) {
    super.render(c);

    c.drawRect(size.toRect(), white);
    c.drawRect(const Rect.fromLTWH(0, 0, 3, 3), red);
    c.drawRect(Rect.fromLTWH(width / 2, height / 2, 3, 3), blue);
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += speed * dt;
    angle %= 2 * math.pi;
  }

  @override
  void onMount() {
    super.onMount();
    size.setValues(squareSize, squareSize);
    anchor = Anchor.center;
  }
}

class MyGame extends BaseGame with DoubleTapDetector, TapDetector {
  bool running = true;

  @override
  Future<void> onLoad() async {
    add(
      Square()
        ..x = 100
        ..y = 100,
    );
  }

  @override
  void onTapUp(TapUpInfo info) {
    final touchArea = RectExtension.fromVector2Center(
      center: info.eventPosition.game,
      width: 20,
      height: 20,
    );

    final handled = components.any((c) {
      if (c is PositionComponent && c.toRect().overlaps(touchArea)) {
        remove(c);
        return true;
      }
      return false;
    });

    if (!handled) {
      add(Square()
        ..x = touchArea.left
        ..y = touchArea.top);
    }
  }

  @override
  void onDoubleTap() {
    if (running) {
      pauseEngine();
    } else {
      resumeEngine();
    }

    running = !running;
  }
}
