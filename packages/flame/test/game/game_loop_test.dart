import 'package:flame/src/game/game_loop.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameLoop step', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('works when game loop is paused', () {
      var tickCount = 0;
      final gameLoop = GameLoop((dt) => ++tickCount);

      gameLoop.step(1);
      expect(tickCount, 1);
    });

    test('does not work when game loop is active', () {
      var tickCount = 0;
      final gameLoop = GameLoop((dt) => ++tickCount);
      gameLoop.start();

      gameLoop.step(1);
      expect(tickCount, 0);
    });

    test('overrides step time correctly', () {
      var elapsedTime = 0.0;
      const frameTime30 = 1 / 30;
      const frameTime120 = 1 / 120;

      final gameLoop = GameLoop((dt) => elapsedTime += dt);

      gameLoop.step(frameTime30);
      expectDouble(elapsedTime, frameTime30);

      gameLoop.step(frameTime120);
      expectDouble(elapsedTime, frameTime30 + frameTime120);
    });
  });
}
