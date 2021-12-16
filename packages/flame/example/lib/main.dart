import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

/// This example simply adds a rotating white square on the screen, if you press
/// somewhere other than on the existing square another square will be added and
/// if you press on a square it will be removed.
class MyGame extends FlameGame with DoubleTapDetector, HasTappables {
  bool running = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(Square(Vector2(100, 200)));
  }

  @override
  void onTapUp(int id, TapUpInfo info) {
    super.onTapUp(id, info);
    final touchPoint = info.eventPosition.game;
    final handled = children.any((c) => c.shouldRemove);

    if (!handled) {
      add(Square(touchPoint));
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

class Square extends PositionComponent with Tappable {
  static const speed = 0.25;
  static const squareSize = 128.0;

  static Paint white = BasicPalette.white.paint();
  static Paint red = BasicPalette.red.paint();
  static Paint blue = BasicPalette.blue.paint();

  Square(Vector2 position) : super(position: position);

  @override
  void render(Canvas c) {
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
  Future<void> onLoad() async {
    super.onLoad();
    size.setValues(squareSize, squareSize);
    anchor = Anchor.center;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    removeFromParent();
    return true;
  }
}
