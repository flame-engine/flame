import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _PanGame extends FlameGame with PanDetector {
  bool panStarted = false;
  bool panEnded = false;

  @override
  void onPanStart(_) {
    panStarted = true;
  }

  @override
  void onPanEnd(_) {
    panEnded = true;
  }
}

void main() {
  final panGame = FlameTester(_PanGame.new);

  group('GameWidget - PanDetector', () {
    panGame.testGameWidget(
      'register drags',
      verify: (game, tester) async {
        await tester.drag(
          find.byGame<_PanGame>(),
          const Offset(50, 0),
        );

        expect(game.panStarted, isTrue);
        expect(game.panEnded, isTrue);
      },
    );
  });
}
