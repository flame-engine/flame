import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: SpaceShooterGame()));
}

class SpaceShooterGame extends FlameGame with DragCallbacks {
  late Player player;

  @override
  Future<void> onLoad() async {
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('assets/images/stars_0.png'),
        ParallaxImageData('assets/images/stars_1.png'),
        ParallaxImageData('assets/images/stars_2.png'),
      ],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);

    player = Player();
    add(player);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    player.move(event.localDelta);
  }
}

class Player extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Player()
    : super(
        size: Vector2(100, 150),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'assets/images/player.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2(32, 48),
      ),
    );

    position = game.size / 2;
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}
