import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class _GameWithTapables extends BaseGame with HasTapableComponents {}

class _GameWithoutTapables extends BaseGame {}

class TapableComponent extends PositionComponent with Tapable {}

void main() {
  group('tapables test', () {
    test('make sure they cannot be added to invalid games', () async {
      final game1 = _GameWithTapables();
      game1.onResize(Vector2.all(100));
      // should be ok
      await game1.add(TapableComponent());

      final game2 = _GameWithoutTapables();
      game2.onResize(Vector2.all(100));

      expect(
        () => game2.add(TapableComponent()),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
