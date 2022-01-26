import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _GameWithTappables extends FlameGame with HasTappables {}

class _TappableComponent extends PositionComponent with Tappable {}

void main() {
  final withTappables = FlameTester(() => _GameWithTappables());

  group('Tappable', () {
    withTappables.test(
      'make sure Tappables can be added to valid games',
      (game) async {
        game.add(_TappableComponent());
        await game.ready();
      },
    );

    flameGame.test(
      'make sure Tappables cannot be added to invalid games',
      (game) {
        expect(
          () async {
            game.add(_TappableComponent());
            await game.ready();
          },
          failsAssert(
            'Tappable Components can only be added to a FlameGame with '
            'HasTappables',
          ),
        );
      },
    );
  });
}
