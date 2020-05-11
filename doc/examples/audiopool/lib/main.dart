import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/audio_pool.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Size size = await Flame.util.initialDimensions();
  final MyGame game = MyGame(size);
  runApp(game.widget);
}

final regular = TextConfig(color: BasicPalette.white.color);
final pool = AudioPool('laser.mp3');
final black = BasicPalette.black.paint;

class MyGame extends BaseGame {
  MyGame(Size screenSize) {
    size = screenSize;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), black);
    regular.render(canvas, 'hit me!', Position.fromSize(size).div(2),
        anchor: Anchor.center);
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownDetails details) {
    super.onTapDown(details);
    pool.start();
  }
}
