import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _TapGame extends FlameGame with TapDetector {
  bool tapRegistered = false;

  @override
  void onTap() {
    tapRegistered = true;
  }
}

class _DoubleTapGame extends FlameGame with DoubleTapDetector {
  bool doubleTapRegistered = false;
  Vector2? doubleTapPosition;

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
  final tapGame = FlameTester(() => _TapGame());
  final doubleTapGame = FlameTester(() => _DoubleTapGame());

  group('GameWidget - TapDetectors', () {
    tapGame.widgetTest(
      'can receive taps',
      (game, tester) async {
        await tester.tapAt(const Offset(10, 10));
        expect(game.tapRegistered, isTrue);
      },
    );

    doubleTapGame.widgetTest(
      'can receive double taps',
      (game, tester) async {
        const tapPosition = Offset(10, 10);
        await tester.tapAt(tapPosition);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.tapAt(tapPosition);
        expect(game.doubleTapRegistered, isTrue);
        final tapVector = tapPosition.toVector2();
        expect(game.doubleTapPosition, closeToVector(tapVector.x, tapVector.y));
      },
    );
  });
}
