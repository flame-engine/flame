import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class MyTimerComponent extends TimerComponent {
  int count = 0;

  MyTimerComponent()
      : super(
          period: 1,
          repeat: true,
          removeOnFinish: false,
          autoStart: true,
        );

  @override
  void tick() {
    count++;
  }
}

class NonRepeatingTimerComponent extends TimerComponent {
  NonRepeatingTimerComponent()
      : super(
          period: 1,
          repeat: false,
          removeOnFinish: true,
          autoStart: true,
        );
}

void main() {
  group('TimerComponent', () {
    final tester = FlameTester(() => FlameGame());

    tester.test('runs the tick method', (game) {
      final timer = MyTimerComponent();
      game.add(timer);
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(timer.count, equals(1));
    });

    tester.test('never remove from the game when is repeating', (game) {
      game.add(MyTimerComponent());
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(game.children.length, equals(1));
    });

    tester.test('is removed from the game when is finished', (game) {
      game.add(NonRepeatingTimerComponent());
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(game.children.length, equals(0));
    });

    tester.test('calls callback when provided', (game) {
      var called = false;
      game.add(
        TimerComponent(
          period: 1,
          autoStart: true,
          callback: () {
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
