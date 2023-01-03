import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

void main() {
  final withHasDraggableComponents =
      FlameTester(_GameWithHasDraggableComponents.new);

  group('DragCallbacks', () {
    testWithGame<_GameWithHasDraggableComponents>(
      'make sure they can be added to game with HasDraggableComponents',
      _GameWithHasDraggableComponents.new,
      (game) async {
        await game.add(_DragCallbacksComponent());
        await game.ready();
      },
    );

    testWithFlameGame(
      'make sure DragCallbacks cannot be added to invalid games',
      (game) async {
        expect(
          () => game.ensureAdd(_DragCallbacksComponent()),
          failsAssert(
            'The components with DragCallbacks can only be added to a '
            'FlameGame with '
            'the HasDraggableComponents mixin',
          ),
        );
      },
    );

    testWithGame<_GameWithHasDraggableComponents>(
      'drag event start',
      _GameWithHasDraggableComponents.new,
      (game) async {
        final component = _DragCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        game.onDragStart(
          createDragStartEvents(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(component.containsLocalPoint(Vector2(10, 10)), false);
        expect(game.dragStartEvent, 1);
      },
    );

    testWithGame<_GameWithHasDraggableComponents>(
      'drag event start, update and cancel',
      _GameWithHasDraggableComponents.new,
      (game) async {
        final component = _DragCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        expect(game.dragStartEvent, 0);
        game.onDragStart(
          createDragStartEvents(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        );
        expect(game.dragStartEvent, 1);
        expect(game.dragUpdateEvent, 0);
        expect(game.dragEndEvent, 0);

        game.onDragUpdate(
          createDragUpdateEvents(
            localPosition: const Offset(15, 15),
            globalPosition: const Offset(15, 15),
          ),
        );

        expect(game.containsLocalPoint(Vector2(9, 9)), true);
        expect(game.dragUpdateEvent, 1);

        game.onDragEnd(
          DragEndEvent(
            1,
            DragEndDetails(),
          ),
        );

        expect(game.dragEndEvent, 1);
      },
    );

    testWithGame<_GameWithHasDraggableComponents>(
      'drag event update not called without onDragStart',
      _GameWithHasDraggableComponents.new,
      (game) async {
        final component = _DragCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        expect(game.dragStartEvent, 0);
        expect(game.dragUpdateEvent, 0);

        game.onDragUpdate(
          createDragUpdateEvents(
            localPosition: const Offset(15, 15),
            globalPosition: const Offset(15, 15),
          ),
        );

        expect(game.dragUpdateEvent, 0);
      },
    );

    withHasDraggableComponents.testGameWidget(
      'drag correctly registered handled event',
      setUp: (game, _) async {
        await game.ensureAdd(
          _DragCallbacksComponent()
            ..x = 10
            ..y = 10
            ..width = 10
            ..height = 10,
        );
      },
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(10, 10), const Offset(90, 90));
        expect(game.dragStartEvent, 1);
        expect(game.dragUpdateEvent > 0, isTrue);
        expect(game.dragEndEvent, 1);
        expect(game.dragCancelEvent, 0);
      },
    );

    withHasDraggableComponents.testGameWidget(
      'drag outside of component is not registered as handled',
      setUp: (game, _) async {
        await game.ensureAdd(
          _DragCallbacksComponent()..size = Vector2.all(100),
        );
      },
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(110, 110), const Offset(120, 120));
        expect(game.dragStartEvent, 0);
        expect(game.dragUpdateEvent, 0);
        expect(game.dragEndEvent, 0);
        expect(game.dragCancelEvent, 0);
      },
    );
  });
}

class _GameWithHasDraggableComponents extends FlameGame
    with HasDraggableComponents {
  int dragStartEvent = 0;
  int dragUpdateEvent = 0;
  int dragEndEvent = 0;
  int dragCancelEvent = 0;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (event.handled) {
      dragStartEvent++;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (event.handled) {
      dragUpdateEvent++;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (event.handled) {
      dragEndEvent++;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (event.handled) {
      dragCancelEvent++;
    }
  }
}

class _DragCallbacksComponent extends PositionComponent with DragCallbacks {
  @override
  void onDragStart(DragStartEvent event) {
    event.handled = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    event.handled = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    event.handled = true;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    event.handled = true;
  }
}
