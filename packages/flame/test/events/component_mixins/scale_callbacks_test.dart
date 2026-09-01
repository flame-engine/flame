import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'input_test_helper.dart';

void main() {
  group('ScaleCallbacks', () {
    testWithFlameGame(
      'make sure ScaleCallback components can be added to a FlameGame',
      (game) async {
        game.add(ScaleCallbacksComponent());
        await game.ready();
        expect(game.children.toList()[2], isA<MultiDragScaleDispatcher>());
      },
    );

    testWithFlameGame(
      'removing the last ScaleCallbacks component disables hasScale on the '
      'recognizer',
      (game) async {
        final component = ScaleCallbacksComponent()..size = Vector2.all(10);
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;
        expect(dispatcher.hasScale, isTrue);

        game.remove(component);
        await game.ready();

        expect(dispatcher.hasScale, isFalse);
      },
    );

    testWithFlameGame(
      'hasScale stays true while at least one ScaleCallbacks component remains',
      (game) async {
        final a = ScaleCallbacksComponent()..size = Vector2.all(10);
        final b = ScaleCallbacksComponent()..size = Vector2.all(10);
        await game.ensureAdd(a);
        await game.ensureAdd(b);
        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

        game.remove(a);
        await game.ready();

        expect(dispatcher.hasScale, isTrue);

        game.remove(b);
        await game.ready();

        expect(dispatcher.hasScale, isFalse);
      },
    );
  });
  testWithFlameGame('scale event start', (game) async {
    final component = ScaleCallbacksComponent()
      ..x = 10
      ..y = 10
      ..width = 10
      ..height = 10;
    game.add(component);
    await game.ready();

    expect(game.children.whereType<MultiDragScaleDispatcher>().length, 1);
    game.firstChild<MultiDragScaleDispatcher>()!.onScaleStart(
      createScaleStartEvents(
        game: game,
        localFocalPoint: const Offset(12, 12),
        focalPoint: const Offset(12, 12),
      ),
    );
    expect(component.containsLocalPoint(Vector2(10, 10)), false);
  });

  testWithFlameGame('scale event start, update and end', (game) async {
    final component = ScaleCallbacksComponent()
      ..x = 10
      ..y = 10
      ..width = 10
      ..height = 10;
    await game.ensureAdd(component);
    final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

    dispatcher.onScaleStart(
      createScaleStartEvents(
        game: game,
        localFocalPoint: const Offset(12, 12),
        focalPoint: const Offset(12, 12),
      ),
    );
    expect(component.scaleStartEvent, 1);
    expect(component.scaleUpdateEvent, 0);
    expect(component.scaleEndEvent, 0);

    dispatcher.onScaleUpdate(
      createScaleUpdateEvents(
        game: game,
        localFocalPoint: const Offset(15, 15),
        focalPoint: const Offset(15, 15),
      ),
    );

    expect(game.containsLocalPoint(Vector2(9, 9)), isTrue);
    expect(component.scaleUpdateEvent, equals(1));

    dispatcher.onScaleEnd(ScaleEndEvent(1, ScaleEndDetails()));
    expect(component.scaleEndEvent, equals(1));
  });

  testWithFlameGame(
    'removed scale component receives scale end on update and clears state',
    (game) async {
      final component = ScaleCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      await game.ensureAdd(component);
      final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;

      dispatcher.onScaleStart(
        createScaleStartEvents(
          game: game,
          localFocalPoint: const Offset(12, 12),
          focalPoint: const Offset(12, 12),
        ),
      );
      expect(component.isScaling, isTrue);

      game.remove(component);
      await game.ready();

      dispatcher.onScaleUpdate(
        createScaleUpdateEvents(
          game: game,
          localFocalPoint: const Offset(15, 15),
          focalPoint: const Offset(15, 15),
        ),
      );

      expect(component.scaleEndEvent, equals(1));
      expect(component.isScaling, isFalse);

      dispatcher.onScaleEnd(ScaleEndEvent(1, ScaleEndDetails()));
      expect(component.scaleEndEvent, equals(1));
    },
  );

  testWithFlameGame(
    'scale event update not called without onScaleStart',
    (game) async {
      final component = ScaleCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      await game.ensureAdd(component);
      final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;
      expect(component.scaleStartEvent, equals(0));
      expect(component.scaleUpdateEvent, equals(0));

      dispatcher.onScaleUpdate(
        createScaleUpdateEvents(
          game: game,
          localFocalPoint: const Offset(15, 15),
          focalPoint: const Offset(15, 15),
        ),
      );
      expect(component.scaleUpdateEvent, equals(0));
    },
  );

  testWidgets('scale correctly registered handled event', (tester) async {
    final component = ScaleCallbacksComponent()
      ..x = 100
      ..y = 100
      ..width = 150
      ..height = 150;
    final game = FlameGame(children: [component]);

    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();

    await tester.zoomFrom(
      startLocation1: const Offset(180, 150),
      offset1: const Offset(15, 2),
      startLocation2: const Offset(120, 150),
      offset2: const Offset(-15, -2),
    );

    expect(game.children.length, equals(4));
    expect(component.isMounted, isTrue);

    expect(component.scaleStartEvent, equals(1));
    expect(component.scaleUpdateEvent, greaterThan(0));
    expect(component.scaleEndEvent, equals(1));
  });

  testWidgets(
    'scale outside of component is not registered as handled',
    (tester) async {
      final component = ScaleCallbacksComponent()..size = Vector2.all(100);
      final game = FlameGame(children: [component]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(component.isMounted, isTrue);

      await tester.zoomFrom(
        startLocation1: const Offset(250, 200),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(150, 200),
        offset2: const Offset(-15, -2),
      );

      expect(component.scaleStartEvent, equals(0));
      expect(component.scaleUpdateEvent, equals(0));
      expect(component.scaleEndEvent, equals(0));
    },
  );

  testWithGame(
    'make sure the FlameGame can registers Scale Callbacks on itself',
    ScaleCallbacksGame.new,
    (game) async {
      await game.ready();
      expect(game.children.length, equals(3));
      expect(game.children.elementAt(1), isA<MultiDragScaleDispatcher>());
    },
  );

  testWidgets(
    'scale correctly registered handled event directly on FlameGame',
    (tester) async {
      final game = ScaleCallbacksGame()..onGameResize(Vector2.all(300));
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, equals(3));
      expect(game.isMounted, isTrue);

      await tester.zoomFrom(
        startLocation1: const Offset(50, 100),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(150, 100),
        offset2: const Offset(-15, -2),
      );

      expect(game.scaleStartEvent, equals(1));
      expect(game.scaleUpdateEvent, greaterThan(0));
      expect(game.scaleEndEvent, equals(1));
    },
  );

  testWidgets(
    'isScaled is changed',
    (tester) async {
      final component = ScaleCallbacksComponent()
        ..size = Vector2.all(100)
        ..x = 100
        ..y = 100;

      final game = FlameGame(children: [component]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      // Inside component
      await tester.zoomFrom(
        startLocation1: const Offset(180, 100),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(120, 100),
        offset2: const Offset(-15, -2),
      );

      expect(component.isScaledStateChange, equals(2));

      // Outside component
      await tester.zoomFrom(
        startLocation1: const Offset(330, 300),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(270, 300),
        offset2: const Offset(-15, -2),
      );

      expect(component.isScaledStateChange, equals(2));
    },
  );
  group('HasScalableComponents', () {
    testWidgets(
      'scale event does not affect more than one component',
      (tester) async {
        var nEvents = 0;
        final game = FlameGame(
          children: [
            ScaleWithCallbacksComponent(
              size: Vector2.all(100),
              onScaleStart: (e) => nEvents++,
              onScaleUpdate: (e) => nEvents++,
              onScaleEnd: (e) => nEvents++,
            ),
            SimpleScaleCallbacksComponent(size: Vector2.all(200))
              ..priority = 10,
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        await tester.zoomFrom(
          startLocation1: const Offset(80, 50),
          offset1: const Offset(15, 2),
          startLocation2: const Offset(20, 50),
          offset2: const Offset(-15, -2),
        );
        expect(nEvents, 0);
      },
    );

    testWidgets(
      'scale event can move outside the component bounds and still fire',
      (tester) async {
        var nEvents = 0;
        const intervals = 50;
        final component = ScaleWithCallbacksComponent(
          size: Vector2.all(30),
          position: Vector2.all(100),
          onScaleUpdate: (e) => nEvents++,
        );
        final game = FlameGame(
          children: [component],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();

        const center = Offset(115, 115);
        await tester.timedZoomFrom(
          center.translate(-10, 0),
          const Offset(-30, 0),
          center.translate(10, 0),
          const Offset(30, 0),
          const Duration(milliseconds: 300),
          intervals: intervals,
        );

        expect(nEvents, intervals * 2 - 1);
      },
    );
  });

  group('local coordinates during a scale', () {
    testWithFlameGame(
      'stay available when the focal point leaves the component bounds',
      (game) async {
        Vector2? localStart;
        final component = ScaleWithCallbacksComponent(
          position: Vector2.all(10),
          size: Vector2.all(30),
          onScaleUpdate: (e) => localStart = e.localStartPosition.clone(),
        );
        await game.ensureAdd(component);
        await game.ready();

        final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;
        dispatcher.onScaleStart(
          createScaleStartEvents(game: game, focalPoint: const Offset(20, 20)),
        );
        // The focal point is now far outside the 30x30 component at (10, 10).
        dispatcher.onScaleUpdate(
          createScaleUpdateEvents(
            game: game,
            focalPoint: const Offset(500, 500),
          ),
        );

        // Scales bypass the containment check, so the gesture is not lost and
        // the coordinates keep being computed past the component's edge.
        expect(localStart, Vector2.all(490));
      },
    );

    testWithFlameGame(
      'become unavailable if hit testing stops reaching the component',
      (game) async {
        var updates = 0;
        int? traceLength;
        Vector2? canvasStart;
        Vector2? deviceStart;
        final component = ScaleWithCallbacksComponent(
          position: Vector2.zero(),
          size: Vector2.all(100),
          onScaleUpdate: (e) {
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
        dispatcher.onScaleStart(
          createScaleStartEvents(game: game, focalPoint: const Offset(10, 10)),
        );

        // The ancestor now swallows events, so hit testing no longer reaches
        // the component, but the scale record still points at it.
        gate.ignoreEvents = true;

        dispatcher.onScaleUpdate(
          createScaleUpdateEvents(game: game, focalPoint: const Offset(20, 20)),
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

  testWidgets(
    'scale event scale factor respects camera & zoom',
    (tester) async {
      final game = makeFixedResolutionGame();
      final scales = [];

      game.camera.viewfinder.zoom = 3;

      game.world.add(
        ScaleWithCallbacksComponent(
          position: Vector2.all(-5),
          size: Vector2.all(10),
          onScaleUpdate: (event) {
            scales.add(event.scale);
          },
        ),
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final canvasSize = game.canvasSize;

      final center = (canvasSize / 2).toOffset();
      await tester.timedZoomFrom(
        center.translate(-1, 0),
        const Offset(-20, 0),
        center.translate(1, 0),
        const Offset(20, 0),
        const Duration(milliseconds: 300),
        intervals: 10,
      );

      expect(scales, List.generate(20, (i) => i + 2));
    },
  );

  testWidgets(
    'scale event rotation respects camera & zoom',
    (tester) async {
      final game = makeFixedResolutionGame();
      final rotations = [];

      game.camera.viewfinder.zoom = 3;

      game.world.add(
        ScaleWithCallbacksComponent(
          position: Vector2.all(-5),
          size: Vector2.all(10),
          onScaleUpdate: (event) {
            rotations.add(event.rotation);
          },
        ),
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final canvasSize = game.canvasSize;

      final center = (canvasSize / 2).toOffset();
      await tester.timedZoomFrom(
        center.translate(-1, 0),
        const Offset(0, 20),
        center.translate(1, 0),
        const Offset(0, -20),
        const Duration(milliseconds: 300),
        intervals: 10,
      );

      // computation of angle using trigonometry with triangle having a size
      // of length 1 and one of length i.
      final expected = List.generate(20, (i) => -atan(i + 1));
      for (var i = 0; i < expected.length; i++) {
        expect(rotations[i], closeTo(expected[i], 1e-6)); // tolerance
      }
    },
  );
}
