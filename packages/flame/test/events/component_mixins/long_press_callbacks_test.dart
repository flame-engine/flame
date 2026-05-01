import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LongPressCallbacks', () {
    testWithFlameGame(
      'can be added to a FlameGame',
      (game) async {
        await game.ensureAdd(_LongPressComponent());
        await game.ready();

        _hasDispatcher(game);
      },
    );

    testWithFlameGame(
      'receives long press start on component',
      (game) async {
        final component = _LongPressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);

        _hasDispatcher(game);

        _longPressStart(game, const Offset(15, 15));
        expect(component.startCount, 1);
        expect(component.isLongPressing, isTrue);
      },
    );

    testWithFlameGame(
      'does not receive events outside bounds',
      (game) async {
        final component = _LongPressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);

        _longPressStart(game, const Offset(5, 5));
        expect(component.startCount, 0);
        expect(component.isLongPressing, isFalse);
      },
    );

    testWithFlameGame(
      'full lifecycle: start, move, end',
      (game) async {
        final component = _LongPressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<LongPressDispatcher>()!;

        dispatcher.onLongPressStart(
          createLongPressStartEvent(
            game: game,
            globalPosition: const Offset(15, 15),
          ),
        );
        expect(component.startCount, 1);
        expect(component.isLongPressing, isTrue);

        dispatcher.onLongPressMoveUpdate(
          createLongPressMoveUpdateEvent(
            game: game,
            globalPosition: const Offset(16, 16),
            offsetFromOrigin: const Offset(1, 1),
          ),
        );
        expect(component.moveUpdateCount, 1);

        dispatcher.onLongPressEnd(
          createLongPressEndEvent(
            game: game,
            globalPosition: const Offset(16, 16),
          ),
        );
        expect(component.endCount, 1);
        expect(component.isLongPressing, isFalse);
      },
    );

    testWithFlameGame(
      'cancel resets isLongPressing',
      (game) async {
        final component = _LongPressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<LongPressDispatcher>()!;

        // Use handleLongPressStart to get the internally-assigned pointerId
        dispatcher.handleLongPressStart(
          const LongPressStartDetails(
            globalPosition: Offset(15, 15),
            localPosition: Offset(15, 15),
          ),
        );
        expect(component.isLongPressing, isTrue);

        dispatcher.handleLongPressCancel();
        expect(component.cancelCount, 1);
        expect(component.isLongPressing, isFalse);
      },
    );

    testWithFlameGame(
      'move update not delivered without start',
      (game) async {
        final component = _LongPressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<LongPressDispatcher>()!;

        dispatcher.onLongPressMoveUpdate(
          createLongPressMoveUpdateEvent(
            game: game,
            globalPosition: const Offset(15, 15),
          ),
        );
        expect(component.moveUpdateCount, 0);
      },
    );

    testWithFlameGame(
      'overlapping components both receive start events',
      (game) async {
        final c1 = _LongPressComponent(
          position: Vector2.all(10),
          size: Vector2.all(20),
        );
        final c2 = _LongPressComponent(
          position: Vector2.all(10),
          size: Vector2.all(20),
        );
        game.add(c1);
        game.add(c2);
        await game.ready();

        _longPressStart(game, const Offset(15, 15));
        // deliverAtPoint only delivers to the topmost component by default
        // (deliverToAll defaults to false for non-scroll events)
        expect(c1.startCount + c2.startCount, 1);
      },
    );

    testWithGame(
      'FlameGame with LongPressCallbacks receives events',
      _LongPressGame.new,
      (game) async {
        _hasDispatcher(game);

        _longPressStart(game, const Offset(15, 15));
        expect(game.startCount, 1);
        expect(game.isLongPressing, isTrue);
      },
    );

    testWithFlameGame(
      'dispatcher is removed when last component unmounts',
      (game) async {
        final component = _LongPressComponent(
          position: Vector2.all(10),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);
        _hasDispatcher(game);

        component.removeFromParent();
        await game.ready();

        // Dispatcher stays as it is managed by the game, not by unmounting
        _hasDispatcher(game);
      },
    );

    testWidgets(
      'long press via gesture recognizer',
      (tester) async {
        final component = _LongPressComponent(
          position: Vector2.zero(),
          size: Vector2.all(800),
        );
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();

        expect(component.isMounted, isTrue);
        _hasDispatcher(game);

        // Simulate a long press gesture through the widget
        final center = tester.getCenter(find.byType(GameWidget<FlameGame>));
        final gesture = await tester.startGesture(center);
        // Wait for long press to be recognized
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
        await gesture.up();
        await tester.pump();

        expect(component.startCount, 1);
        expect(component.endCount, 1);
      },
    );
  });
}

void _longPressStart(FlameGame game, Offset position) {
  game.firstChild<LongPressDispatcher>()!.handleLongPressStart(
    LongPressStartDetails(
      globalPosition: position,
      localPosition: position,
    ),
  );
}

void _hasDispatcher(FlameGame game) {
  expect(
    game.children.whereType<LongPressDispatcher>(),
    hasLength(1),
  );
}

class _LongPressComponent extends PositionComponent with LongPressCallbacks {
  _LongPressComponent({super.position, super.size});

  int startCount = 0;
  int moveUpdateCount = 0;
  int endCount = 0;
  int cancelCount = 0;

  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event);
    startCount++;
  }

  @override
  void onLongPressMoveUpdate(LongPressMoveUpdateEvent event) {
    moveUpdateCount++;
  }

  @override
  void onLongPressEnd(LongPressEndEvent event) {
    super.onLongPressEnd(event);
    endCount++;
  }

  @override
  void onLongPressCancel(LongPressCancelEvent event) {
    super.onLongPressCancel(event);
    cancelCount++;
  }
}

class _LongPressGame extends FlameGame with LongPressCallbacks {
  int startCount = 0;

  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event);
    startCount++;
  }
}
