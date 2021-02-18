import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() {
  final game = MyGame();

  final widget = Container(
    padding: const EdgeInsets.all(50),
    color: const Color(0xFFA9A9A9),
    child: GameWidget(
      game: game,
    ),
  );

  runApp(widget);
}

class TapableSquare extends PositionComponent with Tapable {
  Paint _randomPaint() {
    final rng = math.Random();
    final color = Color.fromRGBO(
      rng.nextInt(256),
      rng.nextInt(256),
      rng.nextInt(256),
      0.9,
    );
    return PaletteEntry(color).paint;
  }

  Paint currentPaint;

  TapableSquare({Vector2 position}) {
    currentPaint = _randomPaint();
    size = Vector2.all(100);
    this.position = position ?? Vector2.all(100);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), currentPaint);
  }

  @override
  bool onTapUp(TapUpDetails details) {
    return false;
  }

  @override
  bool onTapDown(TapDownDetails details) {
    angle += 1.0;
    return false;
  }

  @override
  bool onTapCancel() {
    return false;
  }
}

class MyGame extends BaseGame with HasTapableComponents {
  MyGame() {
    add(TapableSquare(position: Vector2(100, 100)));
    add(TapableSquare(position: Vector2(150, 150)));
    add(TapableSquare(position: Vector2(100, 200)));
  }
}
