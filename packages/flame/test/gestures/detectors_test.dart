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

  group('SecondaryTapDetector', () {
    final secondaryTapGame = FlameTester(_SecondaryTapDetectorGame.new);

    secondaryTapGame.testGameWidget(
      'can receive secondary taps',
      verify: (game, tester) async {
        await tester.tapAt(const Offset(10, 10), buttons: kSecondaryButton);

        expect(game.hasOnSecondaryTapDown, isTrue);
        expect(game.hasOnSecondaryTapUp, isTrue);
      },
    );

    secondaryTapGame.testGameWidget(
      'can receive secondaryTapDown',
      verify: (game, tester) async {
        await tester.startGesture(
          const Offset(10, 10),
          buttons: kSecondaryButton,
        );
        expect(game.hasOnSecondaryTapDown, isTrue);
        expect(game.hasOnSecondaryTapUp, isFalse);
      },
    );
    secondaryTapGame.testGameWidget(
      'can receive secondaryTapCancel',
      verify: (game, tester) async {
        await tester.dragFrom(
          const Offset(10, 10),
          const Offset(20, 20),
          buttons: kSecondaryButton,
        );
        expect(game.hasOnSecondaryTapDown, isTrue);
        expect(game.hasOnSecondaryTapCancel, isTrue);
      },
    );

    testWithGame<_SecondaryTapDetectorGame>(
      'can be Secondary Tapped Down',
      _SecondaryTapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleSecondaryTapDown(TapDownDetails());

        expect(game.hasOnSecondaryTapDown, isTrue);
      },
    );

    testWithGame<_SecondaryTapDetectorGame>(
      'can be Secondary Tapped Up',
      _SecondaryTapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleSecondaryTapUp(TapUpDetails(kind: PointerDeviceKind.touch));

        expect(game.hasOnSecondaryTapUp, isTrue);
      },
    );
    testWithGame<_SecondaryTapDetectorGame>(
      'can be Secondary Tapped Canceled',
      _SecondaryTapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleSecondaryTapDown(TapDownDetails());
        game.onSecondaryTapCancel();

        expect(game.hasOnSecondaryTapCancel, isTrue);
      },
    );
  });

  group('TertiaryTapDetector', () {
    final tertiaryTapGame = FlameTester(_TertiaryTapDetectorGame.new);

    tertiaryTapGame.testGameWidget(
      'can receive tertiary taps',
      verify: (game, tester) async {
        await tester.tapAt(const Offset(10, 10), buttons: kTertiaryButton);

        expect(game.hasOnTertiaryTapDown, isTrue);
        expect(game.hasOnTertiaryTapUp, isTrue);
      },
    );

    tertiaryTapGame.testGameWidget(
      'can receive tertiaryTapDown',
      verify: (game, tester) async {
        await tester.startGesture(
          const Offset(10, 10),
          buttons: kTertiaryButton,
        );
        expect(game.hasOnTertiaryTapDown, isTrue);
        expect(game.hasOnTertiaryTapUp, isFalse);
      },
    );
    tertiaryTapGame.testGameWidget(
      'can receive tertiaryTapCancel',
      verify: (game, tester) async {
        await tester.dragFrom(
          const Offset(10, 10),
          const Offset(20, 20),
          buttons: kTertiaryButton,
        );
        expect(game.hasOnTertiaryTapDown, isTrue);
        expect(game.hasOnTertiaryTapCancel, isTrue);
      },
    );

    testWithGame<_TertiaryTapDetectorGame>(
      'can be Secondary Tapped Down',
      _TertiaryTapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleTertiaryTapDown(TapDownDetails());

        expect(game.hasOnTertiaryTapDown, isTrue);
      },
    );

    testWithGame<_TertiaryTapDetectorGame>(
      'can be Secondary Tapped Up',
      _TertiaryTapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleTertiaryTapUp(TapUpDetails(kind: PointerDeviceKind.touch));

        expect(game.hasOnTertiaryTapUp, isTrue);
      },
    );
  });

  group('DoubleTapDetector', () {
    final doubleTapGame = FlameTester(_DoubleTapDetectorGame.new);

    doubleTapGame.testGameWidget(
      'can receive double taps',
      setUp: (game, tester) async {
        await tester.tapAt(const Offset(10, 10));
        await Future<void>.delayed(kDoubleTapMinTime);
        await tester.tapAt(const Offset(10, 10));
      },
      verify: (game, tester) async {
        expect(game.hasOnDoubleTapDown, isTrue);
        expect(game.doubleTapRegistered, isTrue);
      },
    );
    doubleTapGame.testGameWidget(
      'can receive double tapCancel',
      setUp: (game, tester) async {
        await tester.tapAt(const Offset(10, 10));
        await Future<void>.delayed(kDoubleTapMinTime);
        await tester.dragFrom(
          const Offset(10, 10),
          const Offset(20, 20),
        );
      },
      verify: (game, tester) async {
        expect(game.hasOnDoubleTapDown, isTrue);
        expect(game.hasOnDoubleTapCancel, isTrue);
      },
    );

    testWithGame<_DoubleTapDetectorGame>(
      'can be Double Tapped Down',
      _DoubleTapDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleDoubleTapDown(TapDownDetails());

        expect(game.hasOnDoubleTapDown, isTrue);
      },
    );
  });

  group('LongPressDetector', () {
    final longPressGame = FlameTester(_LongPressDetectorGame.new);

    longPressGame.testGameWidget(
      'can register longPress',
      verify: (game, tester) async {
        await tester.longPressAt(const Offset(10, 10));

        expect(game.hasLongPressRegistered, isTrue);
      },
    );
    longPressGame.testGameWidget(
      'can register moving longPress',
      setUp: (game, tester) async {
        final gesture =
            await tester.startGesture(const Offset(10, 10), pointer: 7);

        await Future<void>.delayed(kLongPressTimeout);

        await gesture.moveTo(const Offset(20, 10));

        await gesture.up();
      },
      verify: (game, tester) async {
        expect(game.hasLongPressStarted, isTrue);
        expect(game.hasLongPressMoveUpdated, isTrue);
        expect(game.hasLongPressEnded, isTrue);
      },
    );

    longPressGame.testGameWidget(
      'can register longPressCancel',
      setUp: (game, tester) async {
        final gesture =
            await tester.startGesture(const Offset(10, 10), pointer: 7);

        await gesture.moveTo(const Offset(20, 10));

        await gesture.up();
      },
      verify: (game, tester) async {
        expect(game.hasLongPressCanceled, isTrue);
        expect(game.hasLongPressStarted, isFalse);
      },
    );

    testWithGame<_LongPressDetectorGame>(
      'can be Long Pressed Start',
      _LongPressDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleLongPressStart(const LongPressStartDetails());

        expect(game.hasLongPressStarted, isTrue);
      },
    );
    testWithGame<_LongPressDetectorGame>(
      'can be Long Pressed Move Update',
      _LongPressDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleLongPressMoveUpdate(const LongPressMoveUpdateDetails());

        expect(game.hasLongPressMoveUpdated, isTrue);
      },
    );
    testWithGame<_LongPressDetectorGame>(
      'can be Long Pressed Move End',
      _LongPressDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleLongPressEnd(const LongPressEndDetails());

        expect(game.hasLongPressEnded, isTrue);
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

class _SecondaryTapDetectorGame extends FlameGame with SecondaryTapDetector {
  bool hasOnSecondaryTapUp = false;
  bool hasOnSecondaryTapDown = false;
  bool hasOnSecondaryTapCancel = false;

  @override
  void onSecondaryTapDown(TapDownInfo info) {
    hasOnSecondaryTapDown = true;
  }

  @override
  void onSecondaryTapUp(TapUpInfo info) {
    hasOnSecondaryTapUp = true;
  }

  @override
  void onSecondaryTapCancel() {
    hasOnSecondaryTapCancel = true;
  }
}

class _TertiaryTapDetectorGame extends FlameGame with TertiaryTapDetector {
  bool hasOnTertiaryTapUp = false;
  bool hasOnTertiaryTapDown = false;
  bool hasOnTertiaryTapCancel = false;

  @override
  void onTertiaryTapDown(TapDownInfo info) {
    hasOnTertiaryTapDown = true;
  }

  @override
  void onTertiaryTapUp(TapUpInfo info) {
    hasOnTertiaryTapUp = true;
  }

  @override
  void onTertiaryTapCancel() {
    hasOnTertiaryTapCancel = true;
  }
}

class _DoubleTapDetectorGame extends FlameGame with DoubleTapDetector {
  bool doubleTapRegistered = false;
  bool hasOnDoubleTapDown = false;
  bool hasOnDoubleTapCancel = false;

  @override
  void onDoubleTap() {
    doubleTapRegistered = true;
  }

  @override
  void onDoubleTapCancel() {
    hasOnDoubleTapCancel = true;
  }

  @override
  void onDoubleTapDown(TapDownInfo info) {
    hasOnDoubleTapDown = true;
  }
}

class _LongPressDetectorGame extends FlameGame with LongPressDetector {
  bool hasLongPressRegistered = false;
  bool hasLongPressCanceled = false;
  bool hasLongPressEnded = false;
  bool hasLongPressMoveUpdated = false;
  bool hasLongPressStarted = false;

  @override
  void onLongPress() {
    hasLongPressRegistered = true;
  }

  @override
  void onLongPressCancel() {
    hasLongPressCanceled = true;
  }

  @override
  void onLongPressEnd(LongPressEndInfo info) {
    hasLongPressEnded = true;
  }

  @override
  void onLongPressUp() {}

  @override
  void onLongPressMoveUpdate(LongPressMoveUpdateInfo info) {
    hasLongPressMoveUpdated = true;
  }

  @override
  void onLongPressStart(LongPressStartInfo info) {
    hasLongPressStarted = true;
  }
}

class _MultiDragPanGame extends FlameGame
    with MultiTouchDragDetector, PanDetector {}

class _MultiTapDoubleTapGame extends FlameGame
    with MultiTouchTapDetector, DoubleTapDetector {}
