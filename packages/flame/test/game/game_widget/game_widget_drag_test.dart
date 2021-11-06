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

final horizontalGame = FlameTester(() => HorizontalDragGame());

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

final verticalGame = FlameTester(() => VerticalDragGame());

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

final panGame = FlameTester(() => PanGame());

void main() {
  group('GameWidget - HorizontalDragDetector', () {
    horizontalGame.widgetTest(
      'register drags',
      (game, tester) async {
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
    verticalGame.widgetTest(
      'register drags',
      (game, tester) async {
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
    panGame.widgetTest(
      'register drags',
      (game, tester) async {
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
