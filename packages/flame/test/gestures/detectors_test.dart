import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PanDetector', () {
    final panGame = FlameTester(_PanDetectorGame.new);

    panGame.testGameWidget(
      'can Register pan',
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(10, 10), const Offset(20, 20));

        expect(game.hasPanStart, isTrue);
        expect(game.hasPanDown, isTrue);
        expect(game.hasPanUpdate, isTrue);
        expect(game.hasPanEnd, isTrue);
      },
    );

    testWithGame<_PanDetectorGame>(
      'can receive onPanDown',
      _PanDetectorGame.new,
      (game) async {
        await game.ready();

        game.handlePanDown(DragDownDetails());
        expect(game.hasPanDown, isTrue);
      },
    );

    testWithGame<_PanDetectorGame>(
      'can receive onPanEnd',
      _PanDetectorGame.new,
      (game) async {
        await game.ready();

        game.handlePanEnd(DragEndDetails());
        expect(game.hasPanEnd, isTrue);
      },
    );

    testWithGame<_PanDetectorGame>(
      'can receive onPanStart',
      _PanDetectorGame.new,
      (game) async {
        await game.ready();

        game.handlePanStart(DragStartDetails());
        expect(game.hasPanStart, isTrue);
      },
    );

    testWithGame<_PanDetectorGame>(
      'can receive onPanUpdate',
      _PanDetectorGame.new,
      (game) async {
        await game.ready();

        game.handlePanUpdate(
          DragUpdateDetails(globalPosition: const Offset(10, 10)),
        );
        expect(game.hasPanUpdate, isTrue);
      },
    );
  });
}

class _PanDetectorGame extends FlameGame with PanDetector {
  bool hasPanDown = false;
  bool hasPanCancel = false;
  bool hasPanEnd = false;
  bool hasPanUpdate = false;
  bool hasPanStart = false;

  @override
  void onPanDown(DragDownInfo info) {
    hasPanDown = true;
  }

  @override
  void onPanCancel() {
    hasPanCancel = true;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    hasPanEnd = true;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    hasPanUpdate = true;
  }

  @override
  void onPanStart(DragStartInfo info) {
    hasPanStart = true;
  }
}
