import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'input_test_helper.dart';

void main() {
  group('DragCallbacks', () {
    testWithFlameGame(
      'make sure DragCallback components can be added to a FlameGame',
      (game) async {
        game.add(DragCallbacksComponent());
        await game.ready();
        expect(game.children.toList()[2], isA<MultiDragScaleDispatcher>());
      },
    );

    testWithFlameGame(
      'removing the last DragCallbacks component disables hasDrag on the '
      'recognizer',
      (game) async {
        final component = DragCallbacksComponent()..size = Vector2.all(10);
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;
        expect(dispatcher.hasDrag, isTrue);

        game.remove(component);
        await game.ready();

        expect(dispatcher.hasDrag, isFalse);
      },
    );

    testWithFlameGame(
      'hasDrag stays true while at least one DragCallbacks component remains',
      (game) async {
        final a = DragCallbacksComponent()..size = Vector2.all(10);
        final b = DragCallbacksComponent()..size = Vector2.all(10);
        await game.ensureAdd(a);
        await game.ensureAdd(b);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        game.remove(a);
        await game.ready();

        expect(dispatcher.hasDrag, isTrue);

        game.remove(b);
        await game.ready();

        expect(dispatcher.hasDrag, isFalse);
      },
    );

    testWithFlameGame('drag event start', (game) async {
      final component = DragCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      game.add(component);
      await game.ready();

      expect(game.children.whereType<MultiDragScaleDispatcher>().length, 1);
      game.firstChild<MultiDragScaleDispatcher>()!.onDragStart(
        createDragStartEvents(
          game: game,
          localPosition: const Offset(12, 12),
          globalPosition: const Offset(12, 12),
        ),
      );
      expect(component.containsLocalPoint(Vector2(10, 10)), false);
    });

    testWithFlameGame('drag event start, update and cancel', (game) async {
      final component = DragCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      await game.ensureAdd(component);
      final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

      dispatcher.onDragStart(
        createDragStartEvents(
          game: game,
          localPosition: const Offset(12, 12),
          globalPosition: const Offset(12, 12),
        ),
      );
      expect(component.dragStartEvent, 1);
      expect(component.dragUpdateEvent, 0);
      expect(component.dragEndEvent, 0);

      dispatcher.onDragUpdate(
        createDragUpdateEvents(
          game: game,
          localPosition: const Offset(15, 15),
          globalPosition: const Offset(15, 15),
        ),
      );

      expect(game.containsLocalPoint(Vector2(9, 9)), isTrue);
      expect(component.dragUpdateEvent, equals(1));

      dispatcher.onDragEnd(DragEndEvent(1, DragEndDetails()));
      expect(component.dragEndEvent, equals(1));
    });

    testWithFlameGame(
      'removed dragged component receives cancel on update and clears state',
      (game) async {
        final component = DragCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.isDragged, isTrue);

        game.remove(component);
        await game.ready();

        dispatcher.onDragUpdate(
          createDragUpdateEvents(
            game: game,
            localPosition: const Offset(15, 15),
            globalPosition: const Offset(15, 15),
          ),
        );

        expect(component.dragCancelEvent, equals(1));
        // onDragCancel no longer delegates to onDragEnd.
        expect(component.dragEndEvent, equals(0));
        expect(component.isDragged, isFalse);

        dispatcher.onDragEnd(DragEndEvent(1, DragEndDetails()));
        expect(component.dragCancelEvent, equals(1));
        expect(component.dragEndEvent, equals(0));
      },
    );

    testWithFlameGame(
      'onDragCancel resets isDragged without delegating to onDragEnd',
      (game) async {
        final component = DragCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.isDragged, isTrue);

        dispatcher.onDragCancel(DragCancelEvent(1));

        expect(component.dragCancelEvent, equals(1));
        expect(component.dragEndEvent, equals(0));
        expect(component.isDragged, isFalse);
      },
    );

    testWithFlameGame(
      'drag event update not called without onDragStart',
      (game) async {
        final component = DragCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;
        expect(component.dragStartEvent, equals(0));
        expect(component.dragUpdateEvent, equals(0));

        dispatcher.onDragUpdate(
          createDragUpdateEvents(
            game: game,
            localPosition: const Offset(15, 15),
            globalPosition: const Offset(15, 15),
          ),
        );
        expect(component.dragUpdateEvent, equals(0));
      },
    );

    testWidgets(
      'drag correctly registered handled event',
      (tester) async {
        final component = DragCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, equals(4));
        expect(component.isMounted, isTrue);

        await tester.dragFrom(const Offset(10, 10), const Offset(90, 90));
        expect(component.dragStartEvent, equals(1));
        expect(component.dragUpdateEvent, greaterThan(0));
        expect(component.dragEndEvent, equals(1));
        expect(component.dragCancelEvent, equals(0));
      },
    );

    testWidgets(
      'drag outside of component is not registered as handled',
      (tester) async {
        final component = DragCallbacksComponent()..size = Vector2.all(100);
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(component.isMounted, isTrue);

        await tester.dragFrom(const Offset(110, 110), const Offset(120, 120));
        expect(component.dragStartEvent, equals(0));
        expect(component.dragUpdateEvent, equals(0));
        expect(component.dragEndEvent, equals(0));
        expect(component.dragCancelEvent, equals(0));
      },
    );

    testWithGame(
      'make sure the FlameGame can registers DragCallback on itself',
      DragCallbacksGame.new,
      (game) async {
        await game.ready();
        expect(game.children.length, equals(3));
        expect(game.children.elementAt(1), isA<MultiDragScaleDispatcher>());
      },
    );

    testWidgets(
      'drag correctly registered handled event directly on FlameGame',
      (tester) async {
        final game = DragCallbacksGame()..onGameResize(Vector2.all(300));
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, equals(3));
        expect(game.isMounted, isTrue);

        await tester.dragFrom(const Offset(10, 10), const Offset(90, 90));
        expect(game.dragStartEvent, equals(1));
        expect(game.dragUpdateEvent, greaterThan(0));
        expect(game.dragEndEvent, equals(1));
        expect(game.dragCancelEvent, equals(0));
      },
    );

    testWidgets(
      'isDragged is changed',
      (tester) async {
        final component = DragCallbacksComponent()..size = Vector2.all(100);
        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();

        // Inside component
        await tester.dragFrom(const Offset(10, 10), const Offset(90, 90));
        expect(component.isDraggedStateChange, equals(2));

        // Outside component
        await tester.dragFrom(const Offset(101, 101), const Offset(110, 110));
        expect(component.isDraggedStateChange, equals(2));
      },
    );
  });

  group('local coordinates during a drag', () {
    testWithFlameGame(
      'stay available when the pointer leaves the viewport',
      (game) async {
        // A 100x100 viewport anchored at the top left of the canvas, so
        // viewport coordinates and canvas coordinates line up.
        game.camera = CameraComponent(
          viewport: FixedSizeViewport(100, 100)..anchor = Anchor.topLeft,
        )..viewfinder.anchor = Anchor.topLeft;
        Vector2? localStart;
        Vector2? canvasStart;
        game.world.add(
          DragWithCallbacksComponent(
            position: Vector2.all(10),
            size: Vector2.all(40),
            onDragUpdate: (e) {
              canvasStart = e.canvasStartPosition.clone();
              localStart = e.localStartPosition.clone();
            },
          ),
        );
        await game.ready();

        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;
        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            globalPosition: const Offset(20, 20),
          ),
        );
        // The pointer is now well outside both the component and the viewport.
        dispatcher.onDragUpdate(
          createDragUpdateEvents(
            game: game,
            globalPosition: const Offset(500, 500),
          ),
        );

        // Canvas coordinates are in the same space as the viewport, so this
        // shows the pointer really did leave it.
        expect(canvasStart, Vector2.all(500));
        // And the component still received the point in its own coordinates,
        // offset by its position, past both its bounds and the viewport's.
        expect(localStart, Vector2.all(490));
      },
    );

    testWithFlameGame(
      'become unavailable if hit testing stops reaching the component',
      (game) async {
        var dragStarts = 0;
        var updates = 0;
        int? traceLength;
        Vector2? canvasStart;
        Vector2? deviceStart;
        final component = DragWithCallbacksComponent(
          position: Vector2.zero(),
          size: Vector2.all(100),
          onDragStart: (_) => dragStarts++,
          onDragUpdate: (e) {
            // Everything here is asserted during delivery: reading the event
            // afterwards would find an unwound trace either way.
            updates++;
            traceLength = e.renderingTrace.length;
            expect(() => e.localStartPosition, throwsStateError);
            canvasStart = e.canvasStartPosition.clone();
            deviceStart = e.deviceStartPosition.clone();
          },
        );
        final gate = EventGate(
          position: Vector2.zero(),
          size: Vector2.all(200),
          children: [component],
        );
        await game.ensureAdd(gate);
        await game.ready();

        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;
        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            globalPosition: const Offset(10, 10),
          ),
        );
        expect(dragStarts, equals(1));

        // The ancestor now swallows events, so hit testing no longer reaches
        // the component, but the drag record still points at it.
        gate.ignoreEvents = true;

        dispatcher.onDragUpdate(
          createDragUpdateEvents(
            game: game,
            globalPosition: const Offset(20, 20),
          ),
        );

        // It is still delivered to, but with nothing behind it in the trace.
        expect(updates, equals(1));
        expect(traceLength, equals(0));
        // Canvas and device coordinates never depend on the trace.
        expect(canvasStart, Vector2.all(20));
        expect(deviceStart, Vector2.all(20));
      },
    );
  });

  group('allowsMultiPointerDrag', () {
    testWithFlameGame(
      'defaults to true, so a second pointer starts a second drag',
      (game) async {
        final component = DragCallbacksComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(50);
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            globalPosition: const Offset(20, 20),
          ),
        );
        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            pointerId: 2,
            globalPosition: const Offset(30, 30),
          ),
        );

        expect(component.dragStartEvent, equals(2));
      },
    );

    testWithFlameGame(
      'when false, a second pointer is not delivered while a drag is active',
      (game) async {
        final component = _SingleDragComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(50);
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            globalPosition: const Offset(20, 20),
          ),
        );
        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            pointerId: 2,
            globalPosition: const Offset(30, 30),
          ),
        );
        expect(component.dragStartEvent, equals(1));

        // No follow-ups for the rejected pointer either.
        dispatcher.onDragUpdate(
          createDragUpdateEvents(
            game: game,
            pointerId: 2,
            globalPosition: const Offset(35, 35),
          ),
        );
        dispatcher.onDragEnd(DragEndEvent(2, DragEndDetails()));
        expect(component.dragUpdateEvent, equals(0));
        expect(component.dragEndEvent, equals(0));

        // The accepted pointer still works normally.
        dispatcher.onDragUpdate(
          createDragUpdateEvents(
            game: game,
            globalPosition: const Offset(25, 25),
          ),
        );
        dispatcher.onDragEnd(DragEndEvent(1, DragEndDetails()));
        expect(component.dragUpdateEvent, equals(1));
        expect(component.dragEndEvent, equals(1));
      },
    );

    testWithFlameGame(
      'a new drag is accepted once the previous one ends',
      (game) async {
        final component = _SingleDragComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(50);
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            globalPosition: const Offset(20, 20),
          ),
        );
        dispatcher.onDragEnd(DragEndEvent(1, DragEndDetails()));
        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            pointerId: 2,
            globalPosition: const Offset(30, 30),
          ),
        );

        expect(component.dragStartEvent, equals(2));
      },
    );

    testWithFlameGame(
      'a cancelled drag also frees the component up',
      (game) async {
        final component = _SingleDragComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(50);
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            globalPosition: const Offset(20, 20),
          ),
        );
        dispatcher.onDragCancel(DragCancelEvent(1));
        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            pointerId: 2,
            globalPosition: const Offset(30, 30),
          ),
        );

        expect(component.dragStartEvent, equals(2));
      },
    );

    testWithFlameGame(
      'the rejected pointer falls through to the component below',
      (game) async {
        final below = DragCallbacksComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(50);
        final above = _SingleDragComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(50);
        game.add(below);
        game.add(above);
        await game.ready();
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            globalPosition: const Offset(20, 20),
          ),
        );
        expect(above.dragStartEvent, equals(1));
        expect(below.dragStartEvent, equals(0));

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            pointerId: 2,
            globalPosition: const Offset(30, 30),
          ),
        );
        expect(above.dragStartEvent, equals(1));
        expect(below.dragStartEvent, equals(1));
      },
    );

    testWithFlameGame(
      'gating drags does not gate scale events',
      (game) async {
        final component = _SingleDragScaleComponent()
          ..position = Vector2.all(10)
          ..size = Vector2.all(50);
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            globalPosition: const Offset(20, 20),
          ),
        );
        dispatcher.onDragStart(
          createDragStartEvents(
            game: game,
            pointerId: 2,
            globalPosition: const Offset(30, 30),
          ),
        );
        expect(component.dragStartEvent, equals(1));

        dispatcher.onScaleStart(
          createScaleStartEvents(game: game, focalPoint: const Offset(25, 25)),
        );
        expect(component.scaleStartEvent, equals(1));
      },
    );
  });

  group('HasDraggableComponents', () {
    testWidgets(
      'drags are delivered to DragCallbacks components',
      (tester) async {
        var nDragStartCalled = 0;
        var nDragUpdateCalled = 0;
        var nDragEndCalled = 0;
        var nDragCancelCalled = 0;
        final game = FlameGame(
          children: [
            DragWithCallbacksComponent(
              position: Vector2(20, 20),
              size: Vector2(100, 100),
              onDragStart: (e) => nDragStartCalled++,
              onDragUpdate: (e) => nDragUpdateCalled++,
              onDragEnd: (e) => nDragEndCalled++,
              onDragCancel: (e) => nDragCancelCalled++,
            ),
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        expect(game.children.length, 4);
        expect(game.children.elementAt(1), isA<DragWithCallbacksComponent>());
        expect(game.children.elementAt(2), isA<MultiDragScaleDispatcher>());

        // regular drag
        await tester.timedDragFrom(
          const Offset(50, 50),
          const Offset(20, 0),
          const Duration(milliseconds: 100),
        );
        expect(nDragStartCalled, 1);
        expect(nDragUpdateCalled, 8);
        expect(nDragEndCalled, 1);

        // cancelled drag
        final gesture = await tester.startGesture(const Offset(50, 50));
        await gesture.moveBy(const Offset(20, 20));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(nDragStartCalled, 2);
        expect(nDragCancelCalled, 1);
        // The cancellation must not be reported as a drag end.
        expect(nDragEndCalled, 1);
      },
    );

    testWidgets(
      'tap is not cancelled when a DragCallbacks component is mounted first',
      (tester) async {
        var nDragStartCalled = 0;
        final tapComponent = _TapCounterComponent(
          position: Vector2(20, 20),
          size: Vector2(100, 100),
        );
        final game = FlameGame(
          children: [
            DragWithCallbacksComponent(
              position: Vector2(200, 200),
              size: Vector2(100, 100),
              onDragStart: (e) => nDragStartCalled++,
            ),
            tapComponent,
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        await tester.tapAt(const Offset(50, 50));
        await tester.pump(const Duration(seconds: 1));

        expect(nDragStartCalled, 0);
        expect(tapComponent.nTapDown, 1);
        expect(tapComponent.nTapUp, 1);
        expect(tapComponent.nTapCancel, 0);
      },
    );

    testWidgets(
      'zero-delta pointer moves do not start a drag or cancel a tap',
      (tester) async {
        var nDragStartCalled = 0;
        final tapComponent = _TapCounterComponent(
          position: Vector2(20, 20),
          size: Vector2(100, 100),
        );
        final game = FlameGame(
          children: [
            DragWithCallbacksComponent(
              position: Vector2(200, 200),
              size: Vector2(100, 100),
              onDragStart: (e) => nDragStartCalled++,
            ),
            tapComponent,
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        final gesture = await tester.startGesture(const Offset(50, 50));
        await gesture.moveBy(Offset.zero);
        await gesture.moveBy(Offset.zero);
        await gesture.moveBy(Offset.zero);
        await gesture.up();
        await tester.pump(const Duration(seconds: 1));

        expect(nDragStartCalled, 0);
        expect(tapComponent.nTapDown, 1);
        expect(tapComponent.nTapUp, 1);
        expect(tapComponent.nTapCancel, 0);
      },
    );

    testWidgets(
      'pointer moves below the touch slop do not start a drag',
      (tester) async {
        var nDragStartCalled = 0;
        var nDragUpdateCalled = 0;
        var nDragEndCalled = 0;
        final tapComponent = _TapCounterComponent(
          position: Vector2(20, 20),
          size: Vector2(100, 100),
        );
        final game = FlameGame(
          children: [
            DragWithCallbacksComponent(
              position: Vector2(20, 20),
              size: Vector2(100, 100),
              onDragStart: (e) => nDragStartCalled++,
              onDragUpdate: (e) => nDragUpdateCalled++,
              onDragEnd: (e) => nDragEndCalled++,
            ),
            tapComponent,
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        // Movement below the touch slop is a tap, not a drag.
        var gesture = await tester.startGesture(const Offset(50, 50));
        await gesture.moveBy(const Offset(5, 5));
        await gesture.moveBy(const Offset(5, 5));
        await gesture.up();
        await tester.pump(const Duration(seconds: 1));
        expect(nDragStartCalled, 0);
        expect(nDragUpdateCalled, 0);
        expect(nDragEndCalled, 0);
        expect(tapComponent.nTapUp, 1);
        expect(tapComponent.nTapCancel, 0);

        // Once the accumulated movement exceeds the touch slop the drag
        // starts, and the pending movement is delivered as one update.
        gesture = await tester.startGesture(const Offset(50, 50));
        await gesture.moveBy(const Offset(5, 5));
        await gesture.moveBy(const Offset(20, 20));
        await gesture.up();
        await tester.pump(const Duration(seconds: 1));
        expect(nDragStartCalled, 1);
        expect(nDragUpdateCalled, 1);
        expect(nDragEndCalled, 1);
        expect(tapComponent.nTapUp, 1);
        expect(tapComponent.nTapCancel, 1);
      },
    );

    testWidgets(
      'drag event does not affect more than one component',
      (tester) async {
        var nEvents = 0;
        final game = FlameGame(
          children: [
            DragWithCallbacksComponent(
              size: Vector2.all(100),
              onDragStart: (e) => nEvents++,
              onDragUpdate: (e) => nEvents++,
              onDragEnd: (e) => nEvents++,
            ),
            SimpleDragCallbacksComponent(size: Vector2.all(200)),
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, 5);
        expect(game.children.elementAt(3), isA<MultiDragScaleDispatcher>());

        await tester.timedDragFrom(
          const Offset(20, 20),
          const Offset(5, 5),
          const Duration(seconds: 1),
        );
        expect(nEvents, 0);
      },
    );

    testWidgets(
      'drag event can move outside the component bounds and still fire',
      (tester) async {
        final points = <Vector2>[];
        final game = FlameGame(
          children: [
            DragWithCallbacksComponent(
              size: Vector2.all(95),
              position: Vector2.all(5),
              onDragUpdate: (e) => points.add(e.localStartPosition),
            ),
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, 4);
        expect(game.children.elementAt(2), isA<MultiDragScaleDispatcher>());

        await tester.timedDragFrom(
          const Offset(80, 80),
          const Offset(0, 40),
          const Duration(seconds: 1),
          frequency: 40,
        );
        expect(points.length, 42);
        expect(points.first, Vector2(75, 75));
        expect(
          points.skip(1),
          List.generate(41, (i) => Vector2(75.0, 75.0 + i)),
        );
      },
    );
  });

  testWidgets(
    'drag event delta respects camera & zoom',
    (tester) async {
      // canvas size is 800x600 so this means a 10x logical scale across
      // both dimensions
      final resolution = Vector2(80, 60);
      final game = FlameGame(
        camera: CameraComponent.withFixedResolution(
          width: resolution.x,
          height: resolution.y,
        ),
      );

      game.camera.viewfinder.zoom = 2;

      final deltas = <Vector2>[];
      game.world.add(
        DragWithCallbacksComponent(
          position: Vector2.all(-5),
          size: Vector2.all(10),
          onDragUpdate: (event) => deltas.add(event.localDelta),
        ),
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final canvasSize = game.canvasSize;
      await tester.dragFrom(
        (canvasSize / 2).toOffset(),
        Offset(canvasSize.x / 10, 0),
      );
      final totalDelta = deltas.reduce((a, b) => a + b);
      expect(totalDelta, Vector2(4, 0));
    },
  );

  testWidgets(
    'drag event delta respects widget positioning',
    (tester) async {
      // canvas size is 800x600 so this means a 10x logical scale across
      // both dimensions
      final resolution = Vector2(80, 60);
      final game = FlameGame(
        camera: CameraComponent.withFixedResolution(
          width: resolution.x,
          height: resolution.y,
        ),
      );

      game.camera.viewfinder.zoom = 1 / 2;

      final deltas = <Vector2>[];
      game.world.add(
        DragWithCallbacksComponent(
          position: Vector2.all(-5),
          size: Vector2.all(10),
          onDragUpdate: (event) => deltas.add(event.localDelta),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Positioned(
                left: 100.0,
                top: 200.0,
                width: 800,
                height: 600,
                child: GameWidget(game: game),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final canvasSize = game.canvasSize;

      // no offset
      await tester.dragFrom(
        (canvasSize / 2).toOffset(),
        Offset(canvasSize.x / 10, 0),
      );
      expect(deltas, isEmpty);

      // accounting for offset
      await tester.dragFrom(
        (canvasSize / 2 + Vector2(100, 200)).toOffset(),
        Offset(canvasSize.x / 10, 0),
      );
      expect(deltas, isNotEmpty);
      final totalDelta = deltas.reduce((a, b) => a + b);
      expect(totalDelta, Vector2(16, 0));
    },
  );
}

class _SingleDragComponent extends PositionComponent
    with DragCallbacks, DragCounter {
  @override
  bool get allowsMultiPointerDrag => false;
}

class _SingleDragScaleComponent extends PositionComponent
    with DragCallbacks, DragCounter, ScaleCallbacks, ScaleCounter {
  @override
  bool get allowsMultiPointerDrag => false;
}

class _TapCounterComponent extends PositionComponent with TapCallbacks {
  _TapCounterComponent({super.position, super.size});

  int nTapDown = 0;
  int nTapUp = 0;
  int nTapCancel = 0;

  @override
  void onTapDown(TapDownEvent event) => nTapDown++;

  @override
  void onTapUp(TapUpEvent event) => nTapUp++;

  @override
  void onTapCancel(TapCancelEvent event) => nTapCancel++;
}
