import 'package:flame/extensions.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:test/test.dart';

class TestGame extends Forge2DGame {
  TestGame() : super(zoom: 4.0, gravity: Vector2(0, -10.0));
}

void main() {
  group(
    'Test corresponding position on screen and in the Forge2D world',
    () {
      test('Zero positioned camera should be zero in world', () {
        expect(TestGame().screenToWorld(Vector2.zero()), Vector2.zero());
      });
    },
  );
}
