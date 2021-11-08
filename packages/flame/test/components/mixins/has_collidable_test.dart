import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class MyCollidable extends PositionComponent with HasHitboxes, Collidable {}

void main() {
  group('HasCollidables', () {
    flameGame.test(
      "can't add collidables to a game without HasCollidables",
      (game) {
        const message =
            'You can only use the HasHitboxes/Collidable feature with games '
            'that has the HasCollidables mixin';
        expect(
          () => game.add(MyCollidable()),
          throwsA(
            predicate(
              (e) => e is AssertionError && e.message == message,
            ),
          ),
        );
      },
    );
  });
}
