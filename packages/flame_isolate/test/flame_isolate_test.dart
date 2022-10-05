import 'package:flame/game.dart';
import 'package:flame_isolate/flame_isolate.dart';
import 'package:flame_test/flame_test.dart';

class TestGame extends FlameGame with FlameIsolate {}

final testGame = FlameTester<TestGame>(TestGame.new);

void main() {
  testGame.test(
    'Test running in isolate',
    (game) {},
  );
}
