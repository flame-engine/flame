import 'package:canvas_test/canvas_test.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final withMultiTouchTapDetector =
      GameTester(_GameWithMultiTouchTapDetector.new);

  group('MultiTouchTapDetector', () {
    testWidgets(
      'Game can have MultiTouchTapDetector',
      (tester) async {
        await tester.pumpWidget(
          GameWidget(
            game: _GameWithMultiTouchTapDetector(),
          ),
        );
        expect(tester.takeException(), null);
      },
    );

    withMultiTouchTapDetector.testGameWidget(
      'update game and render canvas',
      verify: (game, tester) async {
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(game.nOnTapDown, 0);
        game.update(0);
        expect(game.updated, true);
        game.render(MockCanvas());
        expect(game.rendered, true);
      },
    );

    withMultiTouchTapDetector.testGameWidget(
      'render canvas and taps are delivered',
      verify: (game, tester) async {
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(game.nOnTapDown, 0);
        game.render(MockCanvas());
        expect(game.rendered, true);

        // regular tap
        await tester.tapAt(const Offset(100, 100));
        await tester.pump(const Duration(milliseconds: 100));
        expect(game.nOnTapDown, 1);
        expect(game.nOnTapUp, 1);
        expect(game.nOnTap, 1);
        expect(game.nOnLongTapDown, 0);
        expect(game.nOnTapCancel, 0);

        // long tap
        await tester.longPressAt(const Offset(100, 100));
        await tester.pump(const Duration(seconds: 1));
        expect(game.nOnTapDown, 2);
        expect(game.nOnTapUp, 2);
        expect(game.nOnTap, 2);
        expect(game.nOnLongTapDown, 1);
        expect(game.nOnTapCancel, 0);

        // cancelled tap
        var gesture = await tester.startGesture(const Offset(100, 100));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(game.nOnTapDown, 3);
        expect(game.nOnTapUp, 2);
        expect(game.nOnTap, 2);
        expect(game.nOnTapCancel, 1);

        // tap cancelled via movement
        gesture = await tester.startGesture(const Offset(100, 100));
        await gesture.moveBy(const Offset(20, 20));
        await tester.pump(const Duration(seconds: 1));
        expect(game.nOnTapDown, 4);
        expect(game.nOnTapUp, 2);
        expect(game.nOnTap, 2);
        expect(game.nOnLongTapDown, 1);
        expect(game.nOnTapCancel, 2);
      },
    );
  });
}

class _GameWithMultiTouchTapDetector extends Game with MultiTouchTapDetector {
  int tapTimes = 0;
  bool updated = false;
  bool rendered = false;

  int nOnTapDown = 0;
  int nOnLongTapDown = 0;
  int nOnTapUp = 0;
  int nOnTap = 0;
  int nOnTapCancel = 0;

  @override
  void render(Canvas canvas) => rendered = true;

  @override
  void update(double dt) => updated = true;

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    nOnTapDown++;
  }

  @override
  void onLongTapDown(int pointerId, TapDownInfo info) {
    super.onLongTapDown(pointerId, info);
    nOnLongTapDown++;
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    super.onTapUp(pointerId, info);
    nOnTapUp++;
  }

  @override
  void onTapCancel(int pointerId) {
    super.onTapCancel(pointerId);
    nOnTapCancel++;
  }

  @override
  void onTap(int pointerId) {
    super.onTap(pointerId);
    nOnTap++;
  }
}
