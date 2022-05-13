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
  final tapGame = FlameTester(_TapGame.new);
  final doubleTapGame = FlameTester(_DoubleTapGame.new);

  group('GameWidget - TapDetectors', () {
    tapGame.testGameWidget(
      'can receive taps',
      verify: (game, tester) async {
        await tester.tapAt(const Offset(10, 10));
        expect(game.tapRegistered, isTrue);
      },
    );

    const tapPosition = Offset(10, 10);
    doubleTapGame.testGameWidget(
      'can receive double taps',
      setUp: (game, tester) async {
        await tester.tapAt(tapPosition);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.tapAt(tapPosition);
      },
      verify: (game, tester) async {
        expect(game.doubleTapRegistered, isTrue);
        final tapVector = tapPosition.toVector2();
        expect(game.doubleTapPosition, closeToVector(tapVector.x, tapVector.y));
      },
    );
  });
}
