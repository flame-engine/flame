import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

void main() {
  group('Draggable', () {
    testWithGame<_GameHasDraggables>(
      'make sure they can be added to game with HasDraggables',
      _GameHasDraggables.new,
      (game) async {
        await game.add(_DraggableComponent());
        await game.ready();
      },
    );

    testWithFlameGame(
      'make sure they cannot be added to invalid games',
      (game) async {
        expect(
          () => game.ensureAdd(_DraggableComponent()),
          failsAssert(
            'Draggable Components can only be added to a FlameGame with '
            'HasDraggables or HasDraggablesBridge',
          ),
        );
      },
    );

    testWithGame<_GameHasDraggables>(
      'can be dragged',
      _GameHasDraggables.new,
      (game) async {
        final component = _DraggableComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        game.onDragStart(
          1,
          DragStartInfo.fromDetails(
            game,
            DragStartDetails(
              localPosition: const Offset(12, 12),
              globalPosition: const Offset(12, 12),
            ),
          ),
        );
        expect(component.hasStartedDragging, true);
      },
    );

    testWithGame<_GameHasDraggables>(
      'when the game has camera zoom, can be dragged',
      _GameHasDraggables.new,
      (game) async {
        final component = _DraggableComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        game.camera.zoom = 1.5;
        game.onDragStart(
          1,
          DragStartInfo.fromDetails(
            game,
            DragStartDetails(
              localPosition: const Offset(15, 15),
              globalPosition: const Offset(15, 15),
            ),
          ),
        );
        expect(component.hasStartedDragging, true);
      },
    );

    testWithGame<_GameHasDraggables>(
      'when the game has a moved camera, dragging works',
      _GameHasDraggables.new,
      (game) async {
        final component = _DraggableComponent()
          ..x = 50
          ..y = 50
          ..width = 10
          ..height = 10;

        await game.ensureAdd(component);
        game.camera.zoom = 1.5;
        game.camera.snapTo(Vector2.all(50));
        game.onDragStart(
          1,
          DragStartInfo.fromDetails(
            game,
            DragStartDetails(
              localPosition: const Offset(5, 5),
              globalPosition: const Offset(5, 5),
            ),
          ),
        );
        expect(component.hasStartedDragging, true);
      },
    );
  });

  testWithGame<_GameHasDraggables>(
    'isDragged is changed',
    _GameHasDraggables.new,
    (game) async {
      final component = _DraggableComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;

      await game.ensureAdd(component);
      expect(component.isDragged, false);
      game.onDragStart(
        1,
        DragStartInfo.fromDetails(
          game,
          DragStartDetails(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        ),
      );
      expect(component.isDragged, true);
      game.onDragEnd(
        1,
        DragEndInfo.fromDetails(
          game,
          DragEndDetails(),
        ),
      );
      expect(component.isDragged, false);
      game.onDragStart(
        1,
        DragStartInfo.fromDetails(
          game,
          DragStartDetails(
            localPosition: const Offset(12, 12),
            globalPosition: const Offset(12, 12),
          ),
        ),
      );
      expect(component.isDragged, true);
      expect(component.hasCanceledDragging, false);
      game.onDragCancel(1);
      expect(component.isDragged, false);
      expect(component.hasCanceledDragging, true);
    },
  );
}

class _GameHasDraggables extends FlameGame with HasDraggables {}

class _DraggableComponent extends PositionComponent with Draggable {
  bool hasStartedDragging = false;
  bool hasCanceledDragging = false;

  @override
  bool onDragStart(DragStartInfo info) {
    hasStartedDragging = true;
    return true;
  }

  @override
  bool onDragCancel() {
    hasCanceledDragging = true;
    return true;
  }
}
