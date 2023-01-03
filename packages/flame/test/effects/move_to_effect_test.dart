import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoveToEffect', () {
    test('simple linear movement', () {
      final game = FlameGame();
      game.onGameResize(Vector2(100, 100));
      final object = PositionComponent()..position = Vector2(3, 4);
      game.add(object);
      game.update(0);

      object.add(
        MoveToEffect(Vector2(5, -1), EffectController(duration: 1)),
      );
      game.update(0.5);
      expect(object.position.x, closeTo(3 * 0.5 + 5 * 0.5, 1e-15));
      expect(object.position.y, closeTo(4 * 0.5 + -1 * 0.5, 1e-15));
      game.update(0.5);
      expect(object.position.x, closeTo(5, 1e-15));
      expect(object.position.y, closeTo(-1, 1e-15));
    });
  });
}
