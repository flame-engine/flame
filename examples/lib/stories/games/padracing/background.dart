import 'dart:ui';

import 'package:examples/stories/games/padracing/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Gradient;

class Background extends PositionComponent
    with HasGameRef<PadRacingGame>, HasPaint {
  Background() : super(size: PadRacingGame.trackSize, priority: 0);

  late Rect _backgroundRect;

  @override
  Future<void> onLoad() async {
    paint = BasicPalette.black.paint();
    _backgroundRect = toRect();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_backgroundRect, paint);
  }
}
