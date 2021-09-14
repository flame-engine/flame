import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class TappableSquare extends PositionComponent with Tappable {
  static Paint _randomPaint() {
    final rng = math.Random();
    final color = Color.fromRGBO(
      rng.nextInt(256),
      rng.nextInt(256),
      rng.nextInt(256),
      0.9,
    );
    return PaletteEntry(color).paint();
  }

  Paint currentPaint;

  TappableSquare({Vector2? position})
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
  bool onTapUp(_) {
    return false;
  }

  @override
  bool onTapDown(_) {
    angle += 1.0;
    return false;
  }

  @override
  bool onTapCancel() {
    return false;
  }
}

class OverlappingTappablesGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(TappableSquare(position: Vector2(100, 100)));
    add(TappableSquare(position: Vector2(150, 150)));
    add(TappableSquare(position: Vector2(100, 200)));
  }
}
