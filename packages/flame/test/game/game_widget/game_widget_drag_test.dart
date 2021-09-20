import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class HorizontalDragGame extends FlameGame with HorizontalDragDetector {
  bool horizontalDragStarted = false;
  bool horizontalDragEnded = false;

  @override
  void onHorizontalDragStart(_) {
    horizontalDragStarted = true;
  }

  @override
  void onHorizontalDragEnd(_) {
    horizontalDragEnded = true;
  }
}

class VerticalDragGame extends FlameGame with VerticalDragDetector {
  bool verticalDragStarted = false;
  bool verticalDragEnded = false;

  @override
  void onVerticalDragStart(_) {
    verticalDragStarted = true;
  }

  @override
  void onVerticalDragEnd(_) {
    verticalDragEnded = true;
  }
}

class PanGame extends FlameGame with PanDetector {
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
  group('GameWidget - HorizontalDragDetector', () {
    flameWidgetTest<HorizontalDragGame>(
      'register drags',
      createGame: () => HorizontalDragGame(),
      verify: (game, tester) async {
        await tester.drag(
          find.byGame<HorizontalDragGame>(),
          const Offset(50, 0),
        );

        expect(game.horizontalDragStarted, isTrue);
        expect(game.horizontalDragEnded, isTrue);
      },
    );
  });
  group('GameWidget - VerticallDragDetector', () {
    flameWidgetTest<VerticalDragGame>(
      'register drags',
      createGame: () => VerticalDragGame(),
      verify: (game, tester) async {
        await tester.drag(
          find.byGame<VerticalDragGame>(),
          const Offset(50, 0),
        );

        expect(game.verticalDragStarted, isTrue);
        expect(game.verticalDragEnded, isTrue);
      },
    );
  });
  group('GameWidget - PanDetector', () {
    flameWidgetTest<PanGame>(
      'register drags',
      createGame: () => PanGame(),
      verify: (game, tester) async {
        await tester.drag(
          find.byGame<PanGame>(),
          const Offset(50, 0),
        );

        expect(game.panStarted, isTrue);
        expect(game.panEnded, isTrue);
      },
    );
  });
}
