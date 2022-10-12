import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MultiTouchDragDetector', () {
    testWidgets(
      'Game cannot have both MultiTouchDragDetector and PanDetector',
      (tester) async {
        await tester.pumpWidget(
          GameWidget(
            game: _MultiDragPanGame(),
          ),
        );
        expect(tester.takeException(), isAssertionError);
      },
    );
  });

  group('MultiTouchTapDetector', () {
    testWidgets(
      'Game can have both MultiTouchTapDetector and DoubleTapDetector',
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

  group('TapDetector', () {
    final tapGame = FlameTester(_TapDetectorGame.new);

    testWithGame<_TapDetectorGame>(
      'can be Tapped Down',
      _TapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleTapDown(TapDownDetails());

        expect(game.hasOnTapDown, isTrue);
      },
    );
    testWithGame<_TapDetectorGame>(
      'can be Tapped Up',
      _TapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleTapUp(TapUpDetails(kind: PointerDeviceKind.touch));

        expect(game.hasOnTapUp, isTrue);
      },
    );
    testWithGame<_TapDetectorGame>(
      'can be Tapped Canceled',
      _TapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleTapDown(TapDownDetails());
        game.onTapCancel();

        expect(game.hasOnTapCancel, isTrue);
      },
    );
    tapGame.testGameWidget(
      'can receive taps',
      verify: (game, tester) async {
        await tester.tapAt(const Offset(10, 10));
        expect(game.tapRegistered, isTrue);
      },
    );
    tapGame.testGameWidget(
      'can receive tapDown',
      verify: (game, tester) async {
        await tester.startGesture(const Offset(10, 10));
        expect(game.hasOnTapDown, isTrue);
        expect(game.hasOnTapUp, isFalse);
      },
    );
    tapGame.testGameWidget(
      'can receive tapCancel',
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(10, 10), const Offset(20, 10));
        expect(game.hasOnTapDown, isTrue);
        expect(game.hasOnTapCancel, isTrue);
      },
    );
  });
}

class _TapDetectorGame extends FlameGame with TapDetector {
  bool hasOnTapUp = false;
  bool hasOnTapDown = false;
  bool hasOnTapCancel = false;
  bool tapRegistered = false;

  @override
  void onTap() {
    tapRegistered = true;
  }

  @override
  void onTapUp(TapUpInfo info) {
    hasOnTapUp = true;
  }

  @override
  void onTapDown(TapDownInfo info) {
    hasOnTapDown = true;
  }

  @override
  void onTapCancel() {
    hasOnTapCancel = true;
  }
}

class _MultiDragPanGame extends FlameGame
    with MultiTouchDragDetector, PanDetector {}

class _MultiTapDoubleTapGame extends FlameGame
    with MultiTouchTapDetector, DoubleTapDetector {}
