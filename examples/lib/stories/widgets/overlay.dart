import 'package:dashbook/dashbook.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

Widget _pauseMenuBuilder(BuildContext buildContext, ExampleGame game) {
  return Center(
    child: Container(
      width: 100,
      height: 100,
      color: const Color(0xFFFF0000),
      child: const Center(
        child: Text('Paused'),
      ),
    ),
  );
}

Widget overlayBuilder(DashbookContext ctx) {
  return GameWidget<ExampleGame>(
    game: ExampleGame()..paused = true,
    overlayBuilderMap: const {
      'PauseMenu': _pauseMenuBuilder,
    },
    initialActiveOverlays: const ['PauseMenu'],
  );
}

class ExampleGame extends FlameGame with TapDetector {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
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
