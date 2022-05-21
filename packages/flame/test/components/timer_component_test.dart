import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyTimerComponent extends TimerComponent {
  int count = 0;

  _MyTimerComponent()
      : super(
          period: 1,
          repeat: true,
          removeOnFinish: false,
        );

  @override
  void onTick() {
    count++;
  }
}

class _NonRepeatingTimerComponent extends TimerComponent {
  _NonRepeatingTimerComponent()
      : super(
          period: 1,
          repeat: false,
          removeOnFinish: true,
        );
}

void main() {
  group('TimerComponent', () {
    final tester = FlameTester(FlameGame.new);

    tester.test('runs the tick method', (game) {
      final timer = _MyTimerComponent();
      game.add(timer);
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(timer.count, equals(1));
    });

    tester.test('never remove from the game when is repeating', (game) {
      game.add(_MyTimerComponent());
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(game.children.length, equals(1));
    });

    tester.test('is removed from the game when is finished', (game) {
      game.add(_NonRepeatingTimerComponent());
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(game.children.length, equals(0));
    });

    tester.test('calls onTick when provided', (game) {
      var called = false;
      game.add(
        TimerComponent(
          period: 1,
          onTick: () {
            called = true;
          },
        ),
      );
      game.update(0);
      game.update(1.2);

      expect(called, isTrue);
    });
  });
}
