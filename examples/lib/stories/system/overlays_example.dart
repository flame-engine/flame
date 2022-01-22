import 'package:dashbook/dashbook.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class OverlaysExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example we show how the overlays system can be used.\n\n
    If you tap the canvas the game will start and if you tap it again it will
    pause.
  ''';

  @override
  Future<void> onLoad() async {
    final animation = await loadSpriteAnimation(
      'animations/chopper.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );

    add(
      SpriteAnimationComponent(
        animation: animation,
      )
        ..position.y = size.y / 2
        ..position.x = 100
        ..anchor = Anchor.center
        ..size = Vector2.all(100),
    );
  }

  @override
  void onTap() {
    if (overlays.isActive('PauseMenu')) {
      overlays.remove('PauseMenu');
      resumeEngine();
    } else {
      overlays.add('PauseMenu');
      pauseEngine();
    }
  }
}

Widget _pauseMenuBuilder(BuildContext buildContext, OverlaysExample game) {
  return Center(
    child: Container(
      width: 100,
      height: 100,
      color: Colors.orange,
      child: const Center(
        child: Text('Paused'),
      ),
    ),
  );
}

Widget overlayBuilder(DashbookContext ctx) {
  return GameWidget<OverlaysExample>(
    game: OverlaysExample()..paused = true,
    overlayBuilderMap: const {
      'PauseMenu': _pauseMenuBuilder,
    },
    initialActiveOverlays: const ['PauseMenu'],
  );
}
