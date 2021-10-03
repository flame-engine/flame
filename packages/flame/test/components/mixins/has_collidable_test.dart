import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class NonCollidableGame extends FlameGame {}

class MyCollidable extends PositionComponent with Hitbox, Collidable {}

void main() {
  group('HasCollidables', () {
    flameTest<NonCollidableGame>(
      "can't add collidables to a game without HasCollidables",
      createGame: () => NonCollidableGame(),
      verify: (game) {
        expect(
          () => game.add(MyCollidable()),
          throwsAssertionError,
        );
      },
    );
  });
}
