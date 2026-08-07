import 'package:flame/events.dart' hide PointerMoveEvent;
import 'package:flame/game.dart';
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
      'Game can have both MultiTouchTapDetector and DoubleTapCallbacks',
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

  group('VerticalDragDetector', () {
    final verticalDragGame = FlameTester(_VerticalDragDetectorGame.new);

    verticalDragGame.testGameWidget(
      'can register vertical drag',
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(10, 10), const Offset(10, 50));

        expect(game.hasVerticalDragDown, isTrue);
        expect(game.hasVerticalDragStart, isTrue);
        expect(game.hasVerticalDragUpdate, isTrue);
        expect(game.hasVerticalDragEnd, isTrue);
      },
    );

    testWithGame<_VerticalDragDetectorGame>(
      'can be Vertical Dragged Down',
      _VerticalDragDetectorGame.new,
      (game) async {
        await game.ready();
        game.handleVerticalDragDown(DragDownDetails());

        expect(game.hasVerticalDragDown, isTrue);
      },
    );

    testWithGame<_VerticalDragDetectorGame>(
      'can be Vertical Dragged Start',
      _VerticalDragDetectorGame.new,
      (game) async {
        await game.ready();

        game.handleVerticalDragStart(DragStartDetails());

        expect(game.hasVerticalDragStart, isTrue);
      },
    );

    testWithGame<_VerticalDragDetectorGame>(
      'can be Vertical Dragged Update',
      _VerticalDragDetectorGame.new,
      (game) async {
        game.handleVerticalDragUpdate(
          DragUpdateDetails(globalPosition: const Offset(10, 10)),
        );

        expect(game.hasVerticalDragUpdate, isTrue);
      },
    );

    testWithGame<_VerticalDragDetectorGame>(
      'can be Vertical Dragged End',
      _VerticalDragDetectorGame.new,
      (game) async {
        game.handleVerticalDragEnd(DragEndDetails());

        expect(game.hasVerticalDragEnd, isTrue);
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
            pressure: 0.4,
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
            pressure: 0.7,
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
            pressure: 0.9,
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
            pressure: 0.2,
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
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
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
        await tester.sendEventToBinding(
          testPointer.scroll(const Offset(0.0, -300.0)),
        );

        expect(game.registeredScrolling, isTrue);
      },
    );
  });
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
  bool hasVerticalDragDown = false;
  bool hasVerticalDragCancel = false;
  bool hasVerticalDragEnd = false;
  bool hasVerticalDragUpdate = false;
  bool hasVerticalDragStart = false;

  @override
  void onVerticalDragDown(DragDownInfo info) {
    hasVerticalDragDown = true;
  }

  @override
  void onVerticalDragCancel() {
    hasVerticalDragCancel = true;
  }

  @override
  void onVerticalDragEnd(DragEndInfo info) {
    hasVerticalDragEnd = true;
  }

  @override
  void onVerticalDragUpdate(DragUpdateInfo info) {
    hasVerticalDragUpdate = true;
  }

  @override
  void onVerticalDragStart(DragStartInfo info) {
    hasVerticalDragStart = true;
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
    with MultiTouchTapDetector, DoubleTapCallbacks {}
