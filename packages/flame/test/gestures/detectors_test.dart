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
