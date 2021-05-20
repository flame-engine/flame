import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components.dart';
import 'package:flame_fire_atlas/flame_fire_atlas.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    final game = ExampleGame();
    runApp(GameWidget(game: game));
  } catch (e) {
    print(e);
  }
}

class ExampleGame extends BaseGame with TapDetector {
  late FireAtlas _atlas;

  @override
  Future<void> onLoad() async {
    _atlas = await loadFireAtlas('caveace.fa');
    add(
      SpriteAnimationComponent(
        size: Vector2(150, 100),
        animation: _atlas.getAnimation('shooting_ptero'),
      )..y = 50,
    );

    add(SpriteAnimationComponent(
      size: Vector2(150, 100),
      animation: _atlas.getAnimation('bomb_ptero'),
    )
      ..y = 50
      ..x = 200);

    add(
      SpriteComponent(size: Vector2(50, 50), sprite: _atlas.getSprite('bullet'))
        ..y = 200,
    );

    add(
      SpriteComponent(size: Vector2(50, 50), sprite: _atlas.getSprite('shield'))
        ..x = 100
        ..y = 200,
    );

    add(
      SpriteComponent(size: Vector2(50, 50), sprite: _atlas.getSprite('ham'))
        ..x = 200
        ..y = 200,
    );
  }

  @override
  void onTapUp(details) {
    final o = details.localPosition;

    add(SpriteAnimationComponent(
      size: Vector2(100, 100),
      animation: _atlas.getAnimation('explosion'),
      removeOnFinish: true,
    )
      ..anchor = Anchor.center
      ..x = o.dx
      ..y = o.dy);
  }
}
