import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_behaviors_example/entities/entities.dart';
import 'package:flame_behaviors_example/main.dart';

class SpawningBehavior extends TappableBehavior<ExampleGame> {
  final _rng = Random();

  @override
  Future<void> onLoad() async {
    await parent.add(nextRandomEntity(parent.size / 2));

    for (var i = 0; i < 5; i++) {
      await parent.add(nextRandomEntity(parent.size / 2));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (event.handled) return;
    parent.add(nextRandomEntity(event.canvasPosition));
  }

  PositionedEntity nextRandomEntity(Vector2 position) {
    final size = Vector2.all(50) + Vector2.random(_rng) * 100;
    final rotationSpeed = 0.5 - _rng.nextDouble();
    final velocity = (Vector2.random(_rng) - Vector2.random(_rng)) * 300;
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];

    return switch (shapeType) {
      Shapes.circle => Circle(
        position: position,
        size: size,
        velocity: velocity,
        rotationSpeed: rotationSpeed,
      ),
      Shapes.rectangle => Rectangle(
        position: position,
        size: size,
        velocity: velocity,
        rotationSpeed: rotationSpeed,
      ),
    };
  }
}

enum Shapes { circle, rectangle }
