import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/has_draggable_components.dart';
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
          localPosition: const Offset(12, 12),
          globalPosition: const Offset(12, 12),
        ),
      );
      expect(component.dragStartEvent, 1);
      expect(component.dragUpdateEvent, 0);
      expect(component.dragEndEvent, 0);

      dispatcher.onDragUpdate(
        createDragUpdateEvents(
          localPosition: const Offset(15, 15),
          globalPosition: const Offset(15, 15),
        ),
      );

      expect(game.containsLocalPoint(Vector2(9, 9)), true);
      expect(component.dragUpdateEvent, 1);

      dispatcher.onDragEnd(DragEndEvent(1, DragEndDetails()));
      expect(component.dragEndEvent, 1);
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
        expect(component.dragStartEvent, 0);
        expect(component.dragUpdateEvent, 0);

        dispatcher.onDragUpdate(
          createDragUpdateEvents(
            localPosition: const Offset(15, 15),
            globalPosition: const Offset(15, 15),
          ),
        );
        expect(component.dragUpdateEvent, 0);
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
        expect(game.children.length, 2);
        expect(component.isMounted, true);

        await tester.dragFrom(const Offset(10, 10), const Offset(90, 90));
        expect(component.dragStartEvent, 1);
        expect(component.dragUpdateEvent > 0, true);
        expect(component.dragEndEvent, 1);
        expect(component.dragCancelEvent, 0);
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
        expect(component.isMounted, true);

        await tester.dragFrom(const Offset(110, 110), const Offset(120, 120));
        expect(component.dragStartEvent, 0);
        expect(component.dragUpdateEvent, 0);
        expect(component.dragEndEvent, 0);
        expect(component.dragCancelEvent, 0);
      },
    );
  });
}

class _DragCallbacksComponent extends PositionComponent with DragCallbacks {
  int dragStartEvent = 0;
  int dragUpdateEvent = 0;
  int dragEndEvent = 0;
  int dragCancelEvent = 0;

  @override
  void onDragStart(DragStartEvent event) {
    event.handled = true;
    dragStartEvent++;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    event.handled = true;
    dragUpdateEvent++;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    event.handled = true;
    dragEndEvent++;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    event.handled = true;
    dragCancelEvent++;
  }
}
