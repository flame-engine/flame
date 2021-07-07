import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class _GameWithTappables extends BaseGame with HasTappableComponents {}

class _GameWithoutTappables extends BaseGame {}

class TappableComponent extends PositionComponent with Tappable {}

void main() {
  group('tappables test', () {
    test('make sure they cannot be added to invalid games', () async {
      final game1 = _GameWithTappables();
      game1.onResize(Vector2.all(100));
      // should be ok
      await game1.add(TappableComponent());

      final game2 = _GameWithoutTappables();
      game2.onResize(Vector2.all(100));

      expect(
        () => game2.add(TappableComponent()),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
