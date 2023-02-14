import 'package:flame/components.dart';
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
    testWithFlameGame('runs the tick method', (game) async {
      final timer = _MyTimerComponent();
      game.add(timer);
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(timer.count, equals(1));
    });

    testWithFlameGame('never remove from the game when is repeating',
        (game) async {
      game.add(_MyTimerComponent());
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(game.children.length, equals(1));
    });

    testWithFlameGame('is removed from the game when is finished',
        (game) async {
      game.add(_NonRepeatingTimerComponent());
      game.update(0);

      game.update(1.2);

      game.update(0);
      expect(game.children.length, equals(0));
    });

    testWithFlameGame('calls onTick when provided', (game) async {
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
