import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DragCallbacks', () {
    testWithFlameGame(
      'make sure DragCallback components can be added to a FlameGame',
      (game) async {
        await game.add(_DragCallbacksComponent());
        await game.ready();
        expect(game.children.toList()[2], isA<MultiDragDispatcher>());
      },
    );

    testWithFlameGame('drag event start', (game) async {
      final component = _DragCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      game.add(component);
      await game.ready();

      expect(game.children.whereType<MultiDragDispatcher>().length, 1);
      game.firstChild<MultiDragDispatcher>()!.onDragStart(
        createDragStartEvents(
          game: game,
          localPosition: const Offset(12, 12),
          globalPosition: const Offset(12, 12),
        ),
      );
      expect(component.containsLocalPoint(Vector2(10, 10)), false);
    });

    testWithFlameGame('drag event start, update and cancel', (game) async {
      final component = _DragCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      await game.ensureAdd(component);
      final dispatcher = game.firstChild<MultiDragDispatcher>()!;

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
      'drag event update not called without onDragStart',
      (game) async {
        final component = _DragCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<MultiDragDispatcher>()!;
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
        final component = _DragCallbacksComponent()
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
        final component = _DragCallbacksComponent()..size = Vector2.all(100);
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
      _DragCallbacksGame.new,
      (game) async {
        await game.ready();
        expect(game.children.length, equals(3));
        expect(game.children.elementAt(1), isA<MultiDragDispatcher>());
      },
    );

    testWidgets(
      'drag correctly registered handled event directly on FlameGame',
      (tester) async {
        final game = _DragCallbacksGame()..onGameResize(Vector2.all(300));
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
        final component = _DragCallbacksComponent()..size = Vector2.all(100);
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

  group('HasDraggableComponents', () {
    testWidgets(
      'drags are delivered to DragCallbacks components',
      (tester) async {
        var nDragStartCalled = 0;
        var nDragUpdateCalled = 0;
        var nDragEndCalled = 0;
        final game = FlameGame(
          children: [
            _DragWithCallbacksComponent(
              position: Vector2(20, 20),
              size: Vector2(100, 100),
              onDragStart: (e) => nDragStartCalled++,
              onDragUpdate: (e) => nDragUpdateCalled++,
              onDragEnd: (e) => nDragEndCalled++,
            ),
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        expect(game.children.length, 4);
        expect(game.children.elementAt(1), isA<_DragWithCallbacksComponent>());
        expect(game.children.elementAt(2), isA<MultiDragDispatcher>());

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
        await gesture.moveBy(const Offset(10, 10));
        await gesture.cancel();
        await tester.pump(const Duration(seconds: 1));
        expect(nDragStartCalled, 2);
        expect(nDragEndCalled, 2);
      },
    );

    testWidgets(
      'drag event does not affect more than one component',
      (tester) async {
        var nEvents = 0;
        final game = FlameGame(
          children: [
            _DragWithCallbacksComponent(
              size: Vector2.all(100),
              onDragStart: (e) => nEvents++,
              onDragUpdate: (e) => nEvents++,
              onDragEnd: (e) => nEvents++,
            ),
            _SimpleDragCallbacksComponent(size: Vector2.all(200)),
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        expect(game.children.length, 5);
        expect(game.children.elementAt(3), isA<MultiDragDispatcher>());

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
            _DragWithCallbacksComponent(
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
        expect(game.children.elementAt(2), isA<MultiDragDispatcher>());

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
      await game.world.add(
        _DragWithCallbacksComponent(
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
        _DragWithCallbacksComponent(
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

mixin _DragCounter on DragCallbacks {
  int dragStartEvent = 0;
  int dragUpdateEvent = 0;
  int dragEndEvent = 0;
  int dragCancelEvent = 0;
  int isDraggedStateChange = 0;

  bool _wasDragged = false;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    event.handled = true;
    dragStartEvent++;
    if (_wasDragged != isDragged) {
      ++isDraggedStateChange;
      _wasDragged = isDragged;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    event.handled = true;
    dragUpdateEvent++;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    event.handled = true;
    dragEndEvent++;
    if (_wasDragged != isDragged) {
      ++isDraggedStateChange;
      _wasDragged = isDragged;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    event.handled = true;
    dragCancelEvent++;
  }
}

class _DragCallbacksComponent extends PositionComponent
    with DragCallbacks, _DragCounter {}

class _DragCallbacksGame extends FlameGame with DragCallbacks, _DragCounter {}

class _DragWithCallbacksComponent extends PositionComponent with DragCallbacks {
  _DragWithCallbacksComponent({
    void Function(DragStartEvent)? onDragStart,
    void Function(DragUpdateEvent)? onDragUpdate,
    void Function(DragEndEvent)? onDragEnd,
    super.position,
    super.size,
  }) : _onDragStart = onDragStart,
       _onDragUpdate = onDragUpdate,
       _onDragEnd = onDragEnd;

  final void Function(DragStartEvent)? _onDragStart;
  final void Function(DragUpdateEvent)? _onDragUpdate;
  final void Function(DragEndEvent)? _onDragEnd;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    return _onDragStart?.call(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    return _onDragUpdate?.call(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    return _onDragEnd?.call(event);
  }
}

class _SimpleDragCallbacksComponent extends PositionComponent
    with DragCallbacks {
  _SimpleDragCallbacksComponent({super.size});
}
