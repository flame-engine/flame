import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TapCallbacks', () {
    testWithFlameGame(
      'make sure TapCallback components can be added to a FlameGame',
      (game) async {
        await game.ensureAdd(_TapCallbacksComponent());
        await game.ready();
        expect(game.children.toList()[2], isA<MultiTapDispatcher>());
      },
    );

    testWithFlameGame('tap event start', (game) async {
      final component = _TapCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      game.add(component);
      await game.ready();

      expect(game.children.whereType<MultiTapDispatcher>().length, equals(1));
      game.firstChild<MultiTapDispatcher>()!.onTapDown(
        createTapDownEvents(
          game: game,
          localPosition: const Offset(12, 12),
          globalPosition: const Offset(12, 12),
        ),
      );
      expect(component.containsLocalPoint(Vector2(10, 10)), false);
    });

    testWithFlameGame(
      'tap up, down event',
      (game) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiTapDispatcher>()!;

        dispatcher.onTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));

        // [onTapUp] will call, if there was an [onTapDown] event before
        dispatcher.onTapUp(
          createTapUpEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );

        expect(component.tapUpEvent, equals(1));
      },
    );

    testWithFlameGame(
      'longTapDown and tapCancel event',
      (game) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiTapDispatcher>()!;

        dispatcher.onTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));

        // [onTapUp] will call, if there was an [onTapDown] event before
        dispatcher.onLongTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.longTapDownEvent, equals(1));

        dispatcher.onTapCancel(
          TapCancelEvent(1),
        );
        expect(component.tapCancelEvent, equals(1));
      },
    );

    testWidgets(
      'tap correctly registered handled event',
      (tester) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, 4);
        expect(component.isMounted, isTrue);

        await tester.tapAt(const Offset(10, 10));
        await tester.pump(const Duration(seconds: 500));
        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(1));
        expect(component.tapCancelEvent, equals(0));
      },
    );

    testWidgets(
      'tap outside of component is not registered as handled',
      (tester) async {
        final component = _TapCallbacksComponent()..size = Vector2.all(100);
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(component.isMounted, isTrue);

        await tester.tapAt(const Offset(110, 110));
        await tester.pump(const Duration(milliseconds: 500));
        expect(component.tapDownEvent, equals(0));
        expect(component.tapUpEvent, equals(0));
        expect(component.longTapDownEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));
      },
    );

    testWidgets(
      'tap that starts inside the component and ends outside is cancelled',
      (tester) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(component.isMounted, isTrue);

        final gesture = await tester.startGesture(const Offset(10, 10));
        await tester.pump(const Duration(milliseconds: 500));
        await gesture.moveTo(const Offset(10, 9));
        await tester.pump(const Duration(milliseconds: 500));
        await gesture.up();

        await tester.pump();

        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(1));
      },
    );

    testWidgets(
      'tap that starts and ends in different positions'
      ' inside the component is handled',
      (tester) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(component.isMounted, isTrue);

        final gesture = await tester.startGesture(const Offset(10, 10));
        await tester.pump(const Duration(milliseconds: 500));
        await gesture.moveTo(const Offset(10, 11));
        await tester.pump(const Duration(milliseconds: 500));
        await gesture.up();

        await tester.pump();

        expect(component.tapDownEvent, equals(1));
        expect(component.tapUpEvent, equals(1));
        expect(component.tapCancelEvent, equals(0));
      },
    );

    testWithGame(
      'make sure the FlameGame can registers TapCallback on itself',
      _TapCallbacksGame.new,
      (game) async {
        await game.ready();
        expect(game.children.length, equals(3));
        expect(game.children.elementAt(1), isA<MultiTapDispatcher>());
      },
    );

    testWidgets(
      'tap correctly registered handled event directly on FlameGame',
      (tester) async {
        final game = _TapCallbacksGame()..onGameResize(Vector2.all(300));
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, equals(3));
        expect(game.isMounted, isTrue);

        await tester.tapAt(const Offset(10, 10));
        await tester.pump(const Duration(seconds: 500));
        expect(game.tapDownEvent, equals(1));
        expect(game.tapUpEvent, equals(1));
        expect(game.longTapDownEvent, equals(0));
        expect(game.tapCancelEvent, equals(0));
      },
    );

    testWithFlameGame(
      'viewport components should get events before world',
      (game) async {
        final component = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final hudComponent = _TapCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final world = World();
        final cameraComponent = CameraComponent(world: world)
          ..viewfinder.anchor = Anchor.topLeft;

        await game.ensureAddAll([world, cameraComponent]);
        await world.ensureAdd(component);
        await cameraComponent.viewport.ensureAdd(hudComponent);
        final dispatcher = game.firstChild<MultiTapDispatcher>()!;

        dispatcher.onTapDown(
          createTapDownEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );

        expect(hudComponent.tapDownEvent, equals(1));
        expect(hudComponent.tapUpEvent, equals(0));
        expect(hudComponent.tapCancelEvent, equals(0));

        expect(component.tapDownEvent, equals(0));
        expect(component.tapUpEvent, equals(0));
        expect(component.tapCancelEvent, equals(0));

        dispatcher.onTapUp(
          createTapUpEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );

        expect(hudComponent.tapUpEvent, equals(1));
        expect(component.tapUpEvent, equals(0));
      },
    );
  });

  testWidgets(
    'taps are delivered to a TapCallbacks component',
    (tester) async {
      var nTapDown = 0;
      var nLongTapDown = 0;
      var nTapCancel = 0;
      var nTapUp = 0;
      final game = FlameGame(
        children: [
          _TapWithCallbacksComponent(
            size: Vector2(200, 100),
            position: Vector2(50, 50),
            onTapDown: (e) => nTapDown++,
            onLongTapDown: (e) => nLongTapDown++,
            onTapCancel: (e) => nTapCancel++,
            onTapUp: (e) => nTapUp++,
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      expect(game.children.length, 4);

      // regular tap
      await tester.tapAt(const Offset(100, 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(nTapDown, 1);
      expect(nTapUp, 1);
      expect(nLongTapDown, 0);
      expect(nTapCancel, 0);

      // long tap
      await tester.longPressAt(const Offset(100, 100));
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDown, 2);
      expect(nTapUp, 2);
      expect(nLongTapDown, 1);
      expect(nTapCancel, 0);

      // cancelled tap
      var gesture = await tester.startGesture(const Offset(100, 100));
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDown, 3);
      expect(nTapUp, 2);
      expect(nTapCancel, 1);

      // tap cancelled via movement
      gesture = await tester.startGesture(const Offset(100, 100));
      await gesture.moveBy(const Offset(20, 20));
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDown, 4);
      expect(nTapUp, 2);
      expect(nTapCancel, 2);
    },
  );

  testWidgets(
    'TapCallbacks component nested in another TapCallbacks component',
    (tester) async {
      var nTapDownChild = 0;
      var nTapDownParent = 0;
      var nTapCancelChild = 0;
      var nTapCancelParent = 0;
      var nTapUpChild = 0;
      var nTapUpParent = 0;
      final game = FlameGame(
        children: [
          _TapWithCallbacksComponent(
            size: Vector2.all(100),
            position: Vector2.zero(),
            onTapDown: (e) => nTapDownParent++,
            onTapUp: (e) => nTapUpParent++,
            onTapCancel: (e) => nTapCancelParent++,
            children: [
              _TapWithCallbacksComponent(
                size: Vector2.all(50),
                position: Vector2.all(25),
                onTapDown: (e) {
                  nTapDownChild++;
                  e.continuePropagation = true;
                },
                onTapCancel: (e) => nTapCancelChild++,
                onTapUp: (e) => nTapUpChild++,
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, 4);
      expect(game.children.elementAt(1).children.length, 1);

      await tester.longPressAt(const Offset(50, 50));
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDownChild, 1);
      expect(nTapDownParent, 1);
      expect(nTapUpChild, 1);
      expect(nTapUpParent, 1);
      expect(nTapCancelChild, 0);
      expect(nTapCancelParent, 0);

      // cancelled tap
      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDownChild, 2);
      expect(nTapDownParent, 2);
      expect(nTapUpChild, 1);
      expect(nTapUpParent, 1);
      expect(nTapCancelChild, 1);
      expect(nTapCancelParent, 1);
    },
  );

  testWidgets(
    'tap events do not propagate down by default',
    (tester) async {
      var nTapDownParent = 0;
      var nTapCancelParent = 0;
      var nTapUpParent = 0;
      final game = FlameGame(
        children: [
          _TapWithCallbacksComponent(
            size: Vector2.all(100),
            position: Vector2.zero(),
            onTapDown: (e) => nTapDownParent++,
            onTapUp: (e) => nTapUpParent++,
            onTapCancel: (e) => nTapCancelParent++,
            children: [
              _SimpleTapCallbacksComponent(size: Vector2.all(100)),
            ],
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, 4);
      expect(game.children.elementAt(1).children.length, 1);

      await tester.longPressAt(const Offset(50, 50));
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDownParent, 0);
      expect(nTapUpParent, 0);
      expect(nTapCancelParent, 0);

      // cancelled tap
      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(nTapDownParent, 0);
      expect(nTapUpParent, 0);
      expect(nTapCancelParent, 0);
    },
  );

  testWidgets(
    'local coordinates during tap events',
    (tester) async {
      TapDownEvent? tapDownEvent;
      final captured = _CapturedTapEvent();
      final game = FlameGame(
        children: [
          PositionComponent(
            size: Vector2.all(400),
            position: Vector2.all(10),
            children: [
              PositionComponent(
                size: Vector2(300, 200),
                scale: Vector2(1.5, 2),
                position: Vector2.all(40),
                children: [
                  _TapWithCallbacksComponent(
                    size: Vector2(100, 50),
                    position: Vector2(50, 50),
                    onTapDown: (e) {
                      tapDownEvent = e;
                      captured.absorb(e);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, 4);
      expect(game.children.elementAt(1).children.length, 1);

      await tester.tapAt(const Offset(200, 200));
      await tester.pump(const Duration(seconds: 1));
      expect(tapDownEvent, isNotNull);
      // devicePosition and canvasPosition do not come from the rendering
      // trace, so they can be read off the event at any time.
      expect(tapDownEvent!.devicePosition, Vector2(200, 200));
      expect(tapDownEvent!.canvasPosition, Vector2(200, 200));
      expect(captured.localPosition, Vector2(50, 25));
      expect(captured.trace[0], Vector2(50, 25));
      expect(captured.trace[1], Vector2(100, 75));
      expect(captured.trace[2], Vector2(190, 190));
      expect(captured.trace[3], Vector2(200, 200));
      expect(captured.parentContext, Vector2(100, 75));

      // The trace is unwound once delivery is over, so the properties derived
      // from it are no longer readable, whichever way the delivery ended.
      expect(tapDownEvent!.renderingTrace, isEmpty);
      expect(() => tapDownEvent!.localPosition, throwsStateError);
      expect(tapDownEvent!.parentContext, isNull);
    },
  );

  testWidgets(
    'parentContext is null when the game itself receives the event',
    (tester) async {
      final captured = _CapturedTapEvent();
      final game = _TapWithCallbacksGame(onTapDownCallback: captured.absorb);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      await tester.tapAt(const Offset(200, 200));
      await tester.pump(const Duration(seconds: 1));

      // The game is the root of the delivery: it has local coordinates of its
      // own, but nothing above it in the trace.
      expect(captured.localPosition, Vector2(200, 200));
      expect(captured.parentContext, isNull);
    },
  );

  testWidgets(
    'parentContext is also available on displacement events',
    (tester) async {
      Vector2? localStart;
      Vector2? parentStart;
      final game = FlameGame(
        children: [
          PositionComponent(
            size: Vector2.all(400),
            position: Vector2.all(10),
            children: [
              _DragWithParentContextComponent(
                size: Vector2.all(200),
                position: Vector2.all(40),
                onDragUpdateCallback: (e) {
                  localStart = e.localStartPosition;
                  parentStart = e.parentContext?.start;
                },
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      await tester.dragFrom(const Offset(100, 100), const Offset(20, 20));

      // The dragged component sits at (40, 40) within its parent.
      expect(localStart, isNotNull);
      expect(parentStart! - localStart!, Vector2.all(40));
    },
  );
}

/// Holds the values that are only readable while an event is being delivered,
/// so that they can be asserted on after the gesture has finished.
class _CapturedTapEvent {
  late final Vector2 localPosition;
  late final Vector2? parentContext;
  late final List<Vector2> trace;

  void absorb(TapDownEvent event) {
    localPosition = event.localPosition;
    parentContext = event.parentContext;
    trace = event.renderingTrace.reversed.toList();
  }
}

class _TapWithCallbacksGame extends FlameGame with TapCallbacks {
  _TapWithCallbacksGame({required this.onTapDownCallback});

  final void Function(TapDownEvent) onTapDownCallback;

  @override
  void onTapDown(TapDownEvent event) => onTapDownCallback(event);
}

class _DragWithParentContextComponent extends PositionComponent
    with DragCallbacks {
  _DragWithParentContextComponent({
    required Vector2 super.position,
    required Vector2 super.size,
    required this.onDragUpdateCallback,
  });

  final void Function(DragUpdateEvent) onDragUpdateCallback;

  @override
  void onDragUpdate(DragUpdateEvent event) => onDragUpdateCallback(event);
}

class _TapWithCallbacksComponent extends PositionComponent with TapCallbacks {
  _TapWithCallbacksComponent({
    required Vector2 super.position,
    required Vector2 super.size,
    super.children,
    this._onTapDown,
    this._onLongTapDown,
    this._onTapUp,
    this._onTapCancel,
  });

  final void Function(TapDownEvent)? _onTapDown;
  final void Function(TapDownEvent)? _onLongTapDown;
  final void Function(TapUpEvent)? _onTapUp;
  final void Function(TapCancelEvent)? _onTapCancel;

  @override
  void onTapDown(TapDownEvent event) => _onTapDown?.call(event);

  @override
  void onLongTapDown(TapDownEvent event) => _onLongTapDown?.call(event);

  @override
  void onTapUp(TapUpEvent event) => _onTapUp?.call(event);

  @override
  void onTapCancel(TapCancelEvent event) => _onTapCancel?.call(event);
}

class _SimpleTapCallbacksComponent extends PositionComponent with TapCallbacks {
  _SimpleTapCallbacksComponent({super.size});
}

mixin _TapCounter on TapCallbacks {
  int tapDownEvent = 0;
  int tapUpEvent = 0;
  int longTapDownEvent = 0;
  int tapCancelEvent = 0;

  @override
  void onTapDown(TapDownEvent event) {
    expect(event.raw, isNotNull);
    tapDownEvent++;
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    expect(event.raw, isNotNull);
    longTapDownEvent++;
  }

  @override
  void onTapUp(TapUpEvent event) {
    expect(event.raw, isNotNull);
    tapUpEvent++;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    tapCancelEvent++;
  }
}

class _TapCallbacksComponent extends PositionComponent
    with TapCallbacks, _TapCounter {}

class _TapCallbacksGame extends FlameGame with TapCallbacks, _TapCounter {}
