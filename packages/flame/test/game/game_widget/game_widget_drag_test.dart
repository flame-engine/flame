import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _HorizontalDragGame extends FlameGame with HorizontalDragDetector {
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

class _VerticalDragGame extends FlameGame with VerticalDragDetector {
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
  final horizontalGame = FlameTester(_HorizontalDragGame.new);
  final verticalGame = FlameTester(_VerticalDragGame.new);
  final panGame = FlameTester(_PanGame.new);

  group('GameWidget - HorizontalDragDetector', () {
    horizontalGame.testGameWidget(
      'register drags',
      verify: (game, tester) async {
        await tester.drag(
          find.byGame<_HorizontalDragGame>(),
          const Offset(50, 0),
        );

        expect(game.horizontalDragStarted, isTrue);
        expect(game.horizontalDragEnded, isTrue);
      },
    );
  });

  group('GameWidget - VerticalDragDetector', () {
    verticalGame.testGameWidget(
      'register drags',
      verify: (game, tester) async {
        await tester.drag(
          find.byGame<_VerticalDragGame>(),
          const Offset(50, 0),
        );

        expect(game.verticalDragStarted, isTrue);
        expect(game.verticalDragEnded, isTrue);
      },
    );
  });

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
