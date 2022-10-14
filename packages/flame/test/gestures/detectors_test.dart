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

  group('VerticalDragDetector', () {
    final verticalDragGame = FlameTester(_VerticalDragDetectorGame.new);

    verticalDragGame.testGameWidget(
      'can register vertical drag',
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(10, 10), const Offset(10, 50));

        expect(game.hasVerticaDragDown, isTrue);
        expect(game.hasVerticaDragStart, isTrue);
        expect(game.hasVerticaDragUpdate, isTrue);
        expect(game.hasVerticaDragEnd, isTrue);
      },
    );

    testWithGame<_VerticalDragDetectorGame>(
      'can be Vertical Dragged Down',
      _VerticalDragDetectorGame.new,
      (game) async {
        await game.ready();
        game.handleVerticalDragDown(DragDownDetails());

        expect(game.hasVerticaDragDown, isTrue);
      },
    );

    testWithGame<_VerticalDragDetectorGame>(
      'can be Vertical Dragged Start',
      _VerticalDragDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleVerticalDragStart(DragStartDetails());

        expect(game.hasVerticaDragStart, isTrue);
      },
    );

    testWithGame<_VerticalDragDetectorGame>(
      'can be Vertical Dragged Update',
      _VerticalDragDetectorGame.new,
      (game) async {
        game.handleVerticalDragUpdate(
          DragUpdateDetails(globalPosition: const Offset(10, 10)),
        );

        expect(game.hasVerticaDragUpdate, isTrue);
      },
    );

    testWithGame<_VerticalDragDetectorGame>(
      'can be Vertical Dragged End',
      _VerticalDragDetectorGame.new,
      (game) async {
        game.handleVerticalDragEnd(DragEndDetails());

        expect(game.hasVerticaDragEnd, isTrue);
      },
    );
  });

  group('HorizontalDragDetector', () {
    final horizontalDragGame = FlameTester(_HorizontalDragDetectorGame.new);

    horizontalDragGame.testGameWidget(
      'can register horizontal drag',
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(10, 10), const Offset(50, 10));

        expect(game.hasHorizontalDragDown, isTrue);
        expect(game.hasHorizontalDragUpdate, isTrue);
        expect(game.hasHorizontalDragEnd, isTrue);
      },
    );

    testWithGame<_HorizontalDragDetectorGame>(
      'can be horizontal Dragged Down',
      _HorizontalDragDetectorGame.new,
      (game) async {
        await game.ready();
        game.handleHorizontalDragDown(DragDownDetails());

        expect(game.hasHorizontalDragDown, isTrue);
      },
    );

    testWithGame<_HorizontalDragDetectorGame>(
      'can be horizontal Dragged Start',
      _HorizontalDragDetectorGame.new,
      (game) async {
        await game.ready();
        game.handleHorizontalDragStart(DragStartDetails());

        expect(game.hasHorizontalDragStart, isTrue);
      },
    );

    testWithGame<_HorizontalDragDetectorGame>(
      'can be horizontal Dragged update',
      _HorizontalDragDetectorGame.new,
      (game) async {
        await game.ready();
        game.handleHorizontalDragUpdate(
          DragUpdateDetails(globalPosition: const Offset(10, 10)),
        );

        expect(game.hasHorizontalDragUpdate, isTrue);
      },
    );

    testWithGame<_HorizontalDragDetectorGame>(
      'can be horizontal Dragged End',
      _HorizontalDragDetectorGame.new,
      (game) async {
        await game.ready();
        game.handleHorizontalDragEnd(DragEndDetails());

        expect(game.hasHorizontalDragEnd, isTrue);
      },
    );
  });

  group('ForcePressDetector', () {
    final forcePressGame = FlameTester(_ForcePressDetectorGame.new);

    forcePressGame.testGameWidget(
      'can register forcePress',
      verify: (game, tester) async {
        const forcePressOffset = Offset(10, 10);

        final pointerValue = tester.nextPointer;

        final gesture = await tester.createGesture();
        await gesture.downWithCustomEvent(
          forcePressOffset,
          PointerDownEvent(
            pointer: pointerValue,
            position: forcePressOffset,
            pressure: 0.0,
            pressureMax: 6.0,
            pressureMin: 0.0,
          ),
        );

        await gesture.updateWithCustomEvent(
          PointerMoveEvent(
            pointer: pointerValue,
            pressure: 0.3,
            pressureMin: 0,
          ),
        );

        expect(game.forcePressStart, equals(0));
        expect(game.forcePressPeaked, equals(0));
        expect(game.forcePressUpdate, equals(0));
        expect(game.forcePressEnded, equals(0));

        await gesture.updateWithCustomEvent(
          PointerMoveEvent(
            pointer: pointerValue,
            pressure: 0.5,
            pressureMin: 0,
          ),
        );

        expect(game.forcePressStart, equals(1));
        expect(game.forcePressPeaked, equals(0));
        expect(game.forcePressUpdate, equals(1));
        expect(game.forcePressEnded, equals(0));

        await gesture.updateWithCustomEvent(
          PointerMoveEvent(
            pointer: pointerValue,
            pressure: 0.9,
            pressureMin: 0,
          ),
        );

        expect(game.forcePressStart, equals(1));
        expect(game.forcePressPeaked, equals(1));
        expect(game.forcePressUpdate, equals(2));
        expect(game.forcePressEnded, equals(0));

        await gesture.up();

        expect(game.forcePressStart, equals(1));
        expect(game.forcePressPeaked, equals(1));
        expect(game.forcePressUpdate, equals(2));
        expect(game.forcePressEnded, equals(1));
      },
    );

    testWithGame<_ForcePressDetectorGame>(
      'can be Force Press started',
      _ForcePressDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleForcePressStart(
          ForcePressDetails(
            globalPosition: const Offset(10, 10),
            pressure: .4,
          ),
        );

        expect(game.forcePressStart, equals(1));
      },
    );

    testWithGame<_ForcePressDetectorGame>(
      'can be Force Press Updated',
      _ForcePressDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleForcePressUpdate(
          ForcePressDetails(
            globalPosition: const Offset(10, 10),
            pressure: .7,
          ),
        );

        expect(game.forcePressUpdate, equals(1));
      },
    );

    testWithGame<_ForcePressDetectorGame>(
      'can be Force Press peaked',
      _ForcePressDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleForcePressPeak(
          ForcePressDetails(
            globalPosition: const Offset(10, 10),
            pressure: .9,
          ),
        );

        expect(game.forcePressPeaked, equals(1));
      },
    );

    testWithGame<_ForcePressDetectorGame>(
      'can be Force Press Ended',
      _ForcePressDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleForcePressEnd(
          ForcePressDetails(
            globalPosition: const Offset(10, 10),
            pressure: .2,
          ),
        );
        expect(game.forcePressEnded, equals(1));
      },
    );
  });

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

  group('ScaleDetector', () {
    final scaleGame = FlameTester(_ScaleDetectorGame.new);

    scaleGame.testGameWidget(
      'can register Scale',
      setUp: (game, tester) async {
        final gesture1 = await tester.createGesture();
        final gesture2 = await tester.createGesture();

        await gesture1.down(const Offset(10, 10));
        await gesture2.down(const Offset(20, 20));

        await gesture1.moveTo(const Offset(15, 10));
        await gesture2.moveTo(const Offset(15, 20));

        await gesture1.up();
        await gesture2.up();
      },
      verify: (game, tester) async {
        expect(game.hasOnScaleStart, isTrue);
        expect(game.hasOnScaleUpdate, isTrue);
        expect(game.hasOnScaleEnd, isTrue);
      },
    );

    testWithGame<_ScaleDetectorGame>(
      'can receive onScaleStart',
      _ScaleDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleScaleStart(ScaleStartDetails());
        expect(game.hasOnScaleStart, isTrue);
      },
    );

    testWithGame<_ScaleDetectorGame>(
      'can receive onScaleUpdate',
      _ScaleDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleScaleUpdate(ScaleUpdateDetails());
        expect(game.hasOnScaleUpdate, isTrue);
      },
    );

    testWithGame<_ScaleDetectorGame>(
      'can receive onScaleEnd',
      _ScaleDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleScaleEnd(ScaleEndDetails());
        expect(game.hasOnScaleEnd, isTrue);
      },
    );
  });

  group('MouseMovementDetector', () {
    final mouseMoveGame = FlameTester(_MouseMovementDetectorGame.new);

    mouseMoveGame.testGameWidget(
      'Can register Mouse movements',
      setUp: (game, tester) async {
        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(const Offset(10, 10));
      },
      verify: (game, tester) async {
        expect(game.hasReceivedMouseMove, isTrue);
      },
    );
  });

  group('ScrollDetector', () {
    final scrollGame = FlameTester(_ScrollDetectorGame.new);

    scrollGame.testGameWidget(
      'Can register Scrolling',
      verify: (game, tester) async {
        const scrollEventLocation = Offset(0, 300);
        final testPointer = TestPointer(1, PointerDeviceKind.mouse);
        testPointer.hover(scrollEventLocation);
        await tester
            .sendEventToBinding(testPointer.scroll(const Offset(0.0, -300.0)));

        expect(game.registeredScrolling, isTrue);
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

class _HorizontalDragDetectorGame extends FlameGame
    with HorizontalDragDetector {
  bool hasHorizontalDragDown = false;
  bool hasHorizontalDragCancel = false;
  bool hasHorizontalDragEnd = false;
  bool hasHorizontalDragUpdate = false;
  bool hasHorizontalDragStart = false;

  @override
  void onHorizontalDragDown(DragDownInfo info) {
    hasHorizontalDragDown = true;
  }

  @override
  void onHorizontalDragStart(DragStartInfo info) {
    hasHorizontalDragStart = true;
  }

  @override
  void onHorizontalDragUpdate(DragUpdateInfo info) {
    hasHorizontalDragUpdate = true;
  }

  @override
  void onHorizontalDragEnd(DragEndInfo info) {
    hasHorizontalDragEnd = true;
  }

  @override
  void onHorizontalDragCancel() {
    hasHorizontalDragCancel = true;
  }
}

class _VerticalDragDetectorGame extends FlameGame with VerticalDragDetector {
  bool hasVerticaDragDown = false;
  bool hasVerticaDragCancel = false;
  bool hasVerticaDragEnd = false;
  bool hasVerticaDragUpdate = false;
  bool hasVerticaDragStart = false;

  @override
  void onVerticalDragDown(DragDownInfo info) {
    hasVerticaDragDown = true;
  }

  @override
  void onVerticalDragCancel() {
    hasVerticaDragCancel = true;
  }

  @override
  void onVerticalDragEnd(DragEndInfo info) {
    hasVerticaDragEnd = true;
  }

  @override
  void onVerticalDragUpdate(DragUpdateInfo info) {
    hasVerticaDragUpdate = true;
  }

  @override
  void onVerticalDragStart(DragStartInfo info) {
    hasVerticaDragStart = true;
  }
}

class _ForcePressDetectorGame extends FlameGame with ForcePressDetector {
  int forcePressStart = 0;
  int forcePressPeaked = 0;
  int forcePressUpdate = 0;
  int forcePressEnded = 0;

  @override
  void onForcePressStart(ForcePressInfo info) {
    forcePressStart++;
  }

  @override
  void onForcePressEnd(ForcePressInfo info) {
    forcePressEnded++;
  }

  @override
  void onForcePressUpdate(ForcePressInfo info) {
    forcePressUpdate++;
  }

  @override
  void onForcePressPeak(ForcePressInfo info) {
    forcePressPeaked++;
  }
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

class _ScaleDetectorGame extends FlameGame with ScaleDetector {
  bool hasOnScaleStart = false;
  bool hasOnScaleUpdate = false;
  bool hasOnScaleEnd = false;

  @override
  void onScaleStart(ScaleStartInfo info) {
    hasOnScaleStart = true;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    hasOnScaleUpdate = true;
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    hasOnScaleEnd = true;
  }
}

class _MouseMovementDetectorGame extends FlameGame with MouseMovementDetector {
  bool hasReceivedMouseMove = false;

  @override
  void onMouseMove(PointerHoverInfo info) {
    hasReceivedMouseMove = true;
  }
}

class _ScrollDetectorGame extends FlameGame with ScrollDetector {
  bool registeredScrolling = false;

  @override
  void onScroll(PointerScrollInfo info) {
    registeredScrolling = true;
  }
}

class _MultiDragPanGame extends FlameGame
    with MultiTouchDragDetector, PanDetector {}

class _MultiTapDoubleTapGame extends FlameGame
    with MultiTouchTapDetector, DoubleTapDetector {}
