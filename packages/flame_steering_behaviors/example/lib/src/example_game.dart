import 'package:example/src/entities/entities.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

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
