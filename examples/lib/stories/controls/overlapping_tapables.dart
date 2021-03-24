import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class TapableSquare extends PositionComponent with Tapable {
  static Paint _randomPaint() {
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

  TapableSquare({Vector2? position})
      : currentPaint = _randomPaint(),
        super(
          position: position ?? Vector2.all(100),
          size: Vector2.all(100),
        );

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

class OverlappingTapablesGame extends BaseGame with HasTapableComponents {
  @override
  Future<void> onLoad() async {
    add(TapableSquare(position: Vector2(100, 100)));
    add(TapableSquare(position: Vector2(150, 150)));
    add(TapableSquare(position: Vector2(100, 200)));
  }
}
