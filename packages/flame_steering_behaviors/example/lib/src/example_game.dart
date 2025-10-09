import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_steering_behaviors_example/src/entities/entities.dart';

const relativeValue = 16.0;

class ExampleGame extends FlameGame with HasCollisionDetection {
  ExampleGame()
    : super(
        children: [
          FpsTextComponent(position: Vector2.zero()),
          ScreenHitbox(),
        ],
      );

  @override
  Future<void> onLoad() async {
    await addAll([
      for (var i = 0; i < 100; i++)
        Dot(position: Vector2.random()..multiply(size)),
    ]);
  }
}
