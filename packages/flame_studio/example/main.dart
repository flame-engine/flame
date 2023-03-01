import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame_studio/flame_studio.dart';
import 'package:flutter/widgets.dart';

void main() {
  runFlameStudio(
    Container(
      color: const Color(0xff6385b9),
      child: GameWidget(game: MyGame()),
    ),
  );
}

class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  void onLoad() {
    final size = findGame()!.canvasSize;
    final random = Random();
    for (var i = 0; i < 10; i++) {
      final speed = random.nextDouble() * 500;
      final angle = random.nextDouble() * 12;
      add(
        Circle(
          radius: random.nextDouble() * 10 + 10,
          position: Vector2(
            (0.8 * random.nextDouble() + 0.1) * size.x,
            (0.8 * random.nextDouble() + 0.1) * size.y,
          ),
          velocity: Vector2(speed * sin(angle), speed * cos(angle)),
        ),
      );
    }
  }
}

class Circle extends CircleComponent {
  Circle({
    required this.velocity,
    required super.position,
    super.radius = 15.0,
  });

  final Vector2 velocity;
  final Vector2 gameSize = Vector2.zero();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    gameSize.setFrom(size);
  }

  @override
  void update(double dt) {
    var newX = x + velocity.x * dt;
    var newY = y + velocity.y * dt;
    if (newX < 0 || newX > gameSize.x - 2 * radius) {
      velocity.x = -velocity.x;
      newX = newX < 0 ? 0 : gameSize.x - 2 * radius;
    }
    if (newY < 0 || newY > gameSize.y - 2 * radius) {
      velocity.y = -velocity.y;
      newY = newY < 0 ? 0 : gameSize.y - 2 * radius;
    }
    position.setValues(newX, newY);
  }
}
