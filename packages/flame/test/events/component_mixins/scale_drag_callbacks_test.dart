import 'package:flame/components.dart';
import 'package:flame/events.dart' hide PointerMoveEvent;
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'input_test_helper.dart';

void main() {
  group('ScaleAndDragCallbacks', () {
    testWithFlameGame(
      '''make sure adding a component with both scale and drag mixins
      adds a MultiDragScaleDispatcher''',
      (game) async {
        await game.add(ScaleDragCallbacksComponent());
        await game.ready();
        expect(game.children.toList()[2], isA<MultiDragScaleDispatcher>());
      },
    );
  });

  testWithFlameGame(
    '''scale and drag events start, update and end on component 
  with both scale and drag mixins ''',
    (game) async {
      final component = ScaleDragCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      await game.ensureAdd(component);
      final scaleCallback = game.firstChild<ScaleCallbacks>()!;
      final dragCallback = game.firstChild<DragCallbacks>()!;

      scaleCallback.onScaleStart(
        createScaleStartEvents(
          game: game,
          localFocalPoint: const Offset(12, 12),
          focalPoint: const Offset(12, 12),
        ),
      );
      expect(component.scaleStartEvent, 1);
      expect(component.scaleUpdateEvent, 0);
      expect(component.scaleEndEvent, 0);

      scaleCallback.onScaleUpdate(
        createScaleUpdateEvents(
          game: game,
          localFocalPoint: const Offset(15, 15),
          focalPoint: const Offset(15, 15),
        ),
      );

      expect(game.containsLocalPoint(Vector2(9, 9)), isTrue);
      expect(component.scaleUpdateEvent, equals(1));

      scaleCallback.onScaleEnd(ScaleEndEvent(1, ScaleEndDetails()));
      expect(component.scaleEndEvent, equals(1));

      dragCallback.onDragStart(
        createDragStartEvents(
          game: game,
          localPosition: const Offset(12, 12),
          globalPosition: const Offset(12, 12),
        ),
      );
      expect(component.dragStartEvent, 1);
      expect(component.dragUpdateEvent, 0);
      expect(component.dragEndEvent, 0);

      dragCallback.onDragUpdate(
        createDragUpdateEvents(
          game: game,
          localPosition: const Offset(15, 15),
          globalPosition: const Offset(15, 15),
        ),
      );

      expect(game.containsLocalPoint(Vector2(9, 9)), isTrue);
      expect(component.dragUpdateEvent, equals(1));

      dragCallback.onDragEnd(DragEndEvent(1, DragEndDetails()));
      expect(component.dragEndEvent, equals(1));
    },
  );

  testWithFlameGame(
    'scale and drag events update not called without onStart',
    (game) async {
      final component = ScaleDragCallbacksComponent()
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

  testWidgets('scale and drag correctly registered handled event', (
    tester,
  ) async {
    final component = ScaleDragCallbacksComponent()
      ..x = 100
      ..y = 100
      ..width = 150
      ..height = 150;
    final game = FlameGame(children: [component]);

    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();

    await zoomFrom(
      tester,
      startLocation1: const Offset(180, 150),
      offset1: const Offset(15, 2),
      startLocation2: const Offset(120, 150),
      offset2: const Offset(-15, -2),
    );
    await tester.pump();
    await tester.pump();

    expect(game.children.length, equals(4));
    expect(component.isMounted, isTrue);

    expect(component.scaleStartEvent, equals(1));
    expect(component.scaleUpdateEvent, greaterThan(0));
    expect(component.scaleEndEvent, equals(1));

    expect(component.dragStartEvent, equals(2));
    expect(component.dragUpdateEvent, greaterThan(0));
    expect(component.dragEndEvent, equals(2));
    expect(component.dragCancelEvent, equals(0));
  });

  testWidgets(
    'scale and outside of component is not registered as handled',
    (tester) async {
      final component = ScaleDragCallbacksComponent()..size = Vector2.all(100);
      final game = FlameGame(children: [component]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(component.isMounted, isTrue);

      await zoomFrom(
        tester,
        startLocation1: const Offset(250, 200),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(150, 200),
        offset2: const Offset(-15, -2),
      );

      expect(component.scaleStartEvent, equals(0));
      expect(component.scaleUpdateEvent, equals(0));
      expect(component.scaleEndEvent, equals(0));
      expect(component.dragStartEvent, equals(0));
      expect(component.dragUpdateEvent, equals(0));
      expect(component.dragEndEvent, equals(0));
    },
  );

  testWithGame(
    'make sure the FlameGame can registers Scale and Drag Callbacks on itself',
    ScaleDragCallbacksGame.new,
    (game) async {
      await game.ready();
      expect(game.children.length, equals(3));
      expect(game.children.elementAt(1), isA<MultiDragScaleDispatcher>());
    },
  );

  testWidgets(
    'scale and drag correctly registered handled event directly on FlameGame',
    (tester) async {
      final game = ScaleDragCallbacksGame()..onGameResize(Vector2.all(300));
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, equals(3));
      expect(game.isMounted, isTrue);
      await tester.pump();
      await tester.pump();

      await zoomFrom(
        tester,
        startLocation1: const Offset(50, 100),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(150, 100),
        offset2: const Offset(-15, -2),
      );

      expect(game.scaleStartEvent, equals(1));
      expect(game.scaleUpdateEvent, greaterThan(0));
      expect(game.scaleEndEvent, equals(1));
      expect(game.dragStartEvent, equals(2));
      expect(game.dragUpdateEvent, greaterThan(0));
      expect(game.dragEndEvent, equals(2));
      expect(game.dragCancelEvent, equals(0));
    },
  );

  testWidgets(
    'isScaling and isDragged is changed',
    (tester) async {
      final component = ScaleDragCallbacksComponent()
        ..size = Vector2.all(100)
        ..x = 100
        ..y = 100;

      final game = FlameGame(children: [component]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      // Inside component
      await zoomFrom(
        tester,
        startLocation1: const Offset(180, 100),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(120, 100),
        offset2: const Offset(-15, -2),
      );

      expect(component.isScaledStateChange, equals(2));
      expect(component.isDraggedStateChange, equals(2));

      // Outside component
      await zoomFrom(
        tester,
        startLocation1: const Offset(330, 300),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(270, 300),
        offset2: const Offset(-15, -2),
      );

      expect(component.isScaledStateChange, equals(2));
      expect(component.isDraggedStateChange, equals(2));
    },
  );

  group('HasScaleAndDragMixins', () {
    testWidgets(
      'scale and drag events does not affect more than one component',
      (tester) async {
        var nEvents = 0;
        final game = FlameGame(
          children: [
            ScaleDragWithCallbacksComponent(
              size: Vector2.all(100),
              onScaleStart: (e) => nEvents++,
              onScaleUpdate: (e) => nEvents++,
              onScaleEnd: (e) => nEvents++,
              onDragStart: (e) => nEvents++,
              onDragEnd: (e) => nEvents++,
              onDragUpdate: (e) => nEvents++,
            ),
            SimpleScaleDragCallbacksComponent(size: Vector2.all(200))
              ..priority = 10,
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        await zoomFrom(
          tester,
          startLocation1: const Offset(80, 50),
          offset1: const Offset(15, 2),
          startLocation2: const Offset(20, 50),
          offset2: const Offset(-15, -2),
        );
        expect(nEvents, 0);
      },
    );

    testWidgets(
      'scale and drag event can move outside the component bounds and fire',
      (tester) async {
        var nScaleEvents = 0;
        var nDragEvents = 0;
        const intervals = 50;
        final component = ScaleDragWithCallbacksComponent(
          size: Vector2.all(30),
          position: Vector2.all(100),
          onScaleUpdate: (e) => nScaleEvents++,
          onDragUpdate: (e) => nDragEvents++,
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
        expect(nScaleEvents, intervals * 2 + 2);
        expect(nDragEvents, intervals * 2 + 2);
      },
    );

    testWidgets(
      'scale event scale factor respects camera & zoom',
      (tester) async {
        final resolution = Vector2(80, 60);
        final game = FlameGame(
          camera: CameraComponent.withFixedResolution(
            width: resolution.x,
            height: resolution.y,
          ),
        );
        final scales = [];

        game.camera.viewfinder.zoom = 3;

        await game.world.add(
          ScaleDragWithCallbacksComponent(
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

        expect(scales.skip(1), List.generate(21, (i) => i + 1));
      },
    );

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
        await game.world.add(
          ScaleDragWithCallbacksComponent(
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
        await game.world.add(
          ScaleDragWithCallbacksComponent(
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
  });

  group('ScaleAndDragInteractions', () {
    testWidgets(
      'scale event triggers both scale and drag',
      (tester) async {
        final resolution = Vector2(80, 60);
        final game = FlameGame(
          camera: CameraComponent.withFixedResolution(
            width: resolution.x,
            height: resolution.y,
          ),
        );

        final component = ScaleDragWithCallbacksComponent(
          position: Vector2.all(-5),
          size: Vector2.all(10),
        );
        await game.world.add(component);
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

        await tester.pump();
        await tester.pump();

        expect(component.scaleStartEvent, equals(1));
        expect(component.scaleUpdateEvent, greaterThan(0));
        expect(component.scaleEndEvent, equals(1));
        expect(component.dragStartEvent, equals(2));
        expect(component.dragUpdateEvent, greaterThan(0));
        expect(component.dragEndEvent, equals(2));
      },
    );

    testWidgets(
      '''adding drag component after scale component 
    upgrade dispatcher to multiDragScaleDispatcher''',
      (tester) async {
        final resolution = Vector2(80, 60);
        final game = FlameGame(
          camera: CameraComponent.withFixedResolution(
            width: resolution.x,
            height: resolution.y,
          ),
        );

        final scaleComponent = ScaleWithCallbacksComponent();
        await game.world.add(scaleComponent);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump(Durations.short1);

        final dragComponent = DragWithCallbacksComponent();
        await game.world.add(dragComponent);

        await tester.pump();
        await tester.pump();
        expect(game.children.toList()[1], isA<MultiDragScaleDispatcher>());
      },
    );

    testWidgets(
      '''adding scale component after drag
     component allows current dragging to continue''',
      (tester) async {
        final resolution = Vector2(80, 60);
        final game = FlameGame(
          camera: CameraComponent.withFixedResolution(
            width: resolution.x,
            height: resolution.y,
          ),
        );
        final dragComponent = DragWithCallbacksComponent(
          position: Vector2.all(-5),
          size: Vector2.all(10),
        );

        await game.world.add(dragComponent);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();

        Future<void> injectScale() async {
          final scaleComponent = ScaleWithCallbacksComponent();
          await game.world.add(scaleComponent);
          await tester.pump();
          expect(dragComponent.isDragged, true);
        }

        final center = (game.canvasSize / 2).toOffset();

        await dragWithInjection(
          tester,
          center,
          const Offset(20, 0),
          const Duration(milliseconds: 200),
          injectScale, // ajout à mi-chemin
        );
      },
    );

    testWidgets(
      '''adding drag component after scale
     component allows current scaling to continue''',
      (tester) async {
        final resolution = Vector2(80, 60);
        final game = FlameGame(
          camera: CameraComponent.withFixedResolution(
            width: resolution.x,
            height: resolution.y,
          ),
        );
        final scaleComponent = ScaleWithCallbacksComponent(
          position: Vector2.all(-5),
          size: Vector2.all(10),
        );

        await game.world.add(scaleComponent);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();

        Future<void> injectDrag() async {
          final dragComponent = DragWithCallbacksComponent();
          await game.world.add(dragComponent);
          await tester.pump();
          expect(scaleComponent.isScaling, true);
        }

        final center = (game.canvasSize / 2).toOffset();

        await _zoomFromWithInjection(
          tester,
          startLocation1: center.translate(-3, 0),
          offset1: const Offset(15, 2),
          startLocation2: center.translate(3, 0),
          offset2: const Offset(-15, -2),
          duration: const Duration(milliseconds: 200),
          onHalfway: injectDrag,
        );
      },
    );
  });
}

Future<void> dragWithInjection(
  WidgetTester tester,
  Offset start,
  Offset delta,
  Duration duration,
  Future<void> Function() onHalfway, {
  int steps = 20,
}) async {
  final gesture = await tester.startGesture(start);
  final dt = duration ~/ steps;

  for (var i = 0; i < steps; i++) {
    if (i == steps ~/ 2) {
      // On est au milieu : injecte ton scale component
      await onHalfway();
    }

    final t = (i + 1) / steps;
    await gesture.moveTo(start + delta * t);
    await tester.pump(dt);
  }

  await gesture.up();
  await tester.pump();
}

Future<void> _zoomFromWithInjection(
  WidgetTester tester, {
  required Offset startLocation1,
  required Offset offset1,
  required Offset startLocation2,
  required Offset offset2,
  required Duration duration,
  required Future<void> Function() onHalfway,
  int steps = 20,
}) async {
  // Start both fingers
  final gesture1 = await tester.startGesture(startLocation1);
  final gesture2 = await tester.startGesture(startLocation2);

  await tester.pump();

  final dt = duration ~/ steps;

  for (var i = 0; i < steps; i++) {
    // Inject custom logic at halfway
    if (i == steps ~/ 2) {
      await onHalfway();
      await tester.pump();
    }

    final t = (i + 1) / steps;

    await gesture1.moveTo(startLocation1 + offset1 * t);
    await gesture2.moveTo(startLocation2 + offset2 * t);

    await tester.pump(dt);
  }

  // Release both gestures
  await gesture1.up();
  await gesture2.up();

  await tester.pump();
}
