import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter_test/flutter_test.dart';

class _MultiDragPanGame extends FlameGame
    with MultiTouchDragDetector, PanDetector {}

class _MultiTapDoubleTapGame extends FlameGame
    with MultiTouchTapDetector, DoubleTapDetector {}

void main() {
  group('apply detectors', () {
    testWidgets(
      'game can not have both MultiTouchDragDetector and PanDetector',
      (tester) async {
        await tester.pumpWidget(
          GameWidget(
            game: _MultiDragPanGame(),
          ),
        );
        expect(tester.takeException(), isInstanceOf<AssertionError>());
      },
    );

    testWidgets(
      'game can have both MultiTouchTapDetector and DoubleTapDetector',
      (tester) async {
        await tester.pumpWidget(
          GameWidget(
            game: _MultiTapDoubleTapGame(),
          ),
        );
        expect(tester.takeException(), null);
      },
    );
  });
}
