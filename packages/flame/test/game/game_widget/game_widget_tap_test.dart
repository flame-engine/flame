import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class TapGame extends FlameGame with TapDetector, DoubleTapDetector {
  bool tapRegistered = false;
  bool doubleTapRegistered = false;
  Vector2? doubleTapPosition;

  @override
  void onTap() {
    tapRegistered = true;
  }

  @override
  void onDoubleTap() {
    doubleTapRegistered = true;
  }

  @override
  void onDoubleTapDown(TapDownInfo info) {
    doubleTapPosition = info.eventPosition.global;
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

    flameWidgetTest<TapGame>(
      'can receive double taps',
      createGame: () => TapGame(),
      verify: (game, tester) async {
        const tapPosition = Offset(10, 10);
        await tester.tapAt(tapPosition);
        await tester.tapAt(tapPosition);
        expect(game.doubleTapRegistered, isTrue);
        expect(game.tapRegistered, isFalse);
        expectVector2(game.doubleTapPosition!, tapPosition.toVector2());
      },
    );
  });
}
