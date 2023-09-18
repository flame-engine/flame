import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/multi_drag_dispatcher.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
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
