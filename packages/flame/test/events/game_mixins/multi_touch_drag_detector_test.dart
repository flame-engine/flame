import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final withMultiTouchFragDetector =
      GameTester(_MultiTouchDragDetectorGame.new);

  group('MultiTouchDragDetector', () {
    testWidgets(
      'Game can have MultiTouchDragDetector',
      (tester) async {
        await tester.pumpWidget(
          GameWidget(
            game: _MultiTouchDragDetectorGame(),
          ),
        );
        expect(tester.takeException(), null);
      },
    );

    withMultiTouchFragDetector.testGameWidget(
      'update game and render canvas',
      verify: (game, tester) async {
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(game.nOnDragStart, 0);
        game.update(0);
        expect(game.updated, true);
        game.render(MockCanvas());
        expect(game.rendered, true);
      },
    );

    withMultiTouchFragDetector.testGameWidget(
      'drags are delivered',
      verify: (game, tester) async {
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(game.nOnDragStart, 0);
        game.render(MockCanvas());
        expect(game.rendered, true);

        // regular drag
        await tester.timedDragFrom(
          const Offset(50, 50),
          const Offset(20, 0),
          const Duration(milliseconds: 100),
        );
        expect(game.nOnDragStart, 1);
        expect(game.nOnDragUpdate, 8);
        expect(game.nOnDragEnd, 1);
        expect(game.nOnDragCancel, 0);

        // cancelled drag
        final gesture = await tester.startGesture(const Offset(50, 50));
        await gesture.moveBy(const Offset(10, 10));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(game.nOnDragStart, 2);
        expect(game.nOnDragEnd, 1);
        expect(game.nOnDragCancel, 1);
      },
    );
  });
}

class _MultiTouchDragDetectorGame extends Game with MultiTouchDragDetector {
  bool updated = false;
  bool rendered = false;

  int nOnDragStart = 0;
  int nOnDragUpdate = 0;
  int nOnDragEnd = 0;
  int nOnDragCancel = 0;

  @override
  void render(Canvas canvas) => rendered = true;

  @override
  void update(double dt) => updated = true;

  @override
  void onDragCancel(int pointerId) {
    super.onDragCancel(pointerId);
    nOnDragCancel++;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
    nOnDragEnd++;
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    nOnDragUpdate++;
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    nOnDragStart++;
  }
}
