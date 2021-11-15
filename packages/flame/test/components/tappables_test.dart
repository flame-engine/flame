import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _GameWithTappables extends FlameGame with HasTappableComponents {}

class _TappableComponent extends PositionComponent with Tappable {}

void main() {
  final withTappables = FlameTester(() => _GameWithTappables());

  group('tappables test', () {
    withTappables.test(
      'make sure Tappables can be added to valid games',
      (game) async {
        await game.ensureAdd(_TappableComponent());
      },
    );

    flameGame.test(
      'make sure Tappables cannot be added to invalid games',
      (game) async {
        const message =
            'Tappable Components can only be added to a FlameGame with '
            'HasTappableComponents';

        expect(
          () => game.add(_TappableComponent()),
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
