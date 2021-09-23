import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class TapGame extends FlameGame with TapDetector {
  bool tapRegistered = false;

  @override
  void onTap() {
    tapRegistered = true;
  }
}

void main() {
  group('GameWidget - TapDetectors', () {
    flameWidgetTest<TapGame>(
      'can receive taps',
      createGame: () => TapGame(),
      verify: (game, tester) async {
        await tester.tapAt(const Offset(10, 10));
        expect(game.tapRegistered, isTrue);
      },
    );
  });
}
