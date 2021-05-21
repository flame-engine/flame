import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

class _GameWithDraggables extends BaseGame with HasDraggableComponents {}

class _GameWithoutDraggables extends BaseGame {}

class DraggableComponent extends PositionComponent with Draggable {
  bool hasStartedDragging = false;

  @override
  bool onDragStart(int pointerId, DragStartInfo event) {
    hasStartedDragging = true;
    return true;
  }
}

void main() {
  group('draggables test', () {
    test('make sure they cannot be added to invalid games', () async {
      final game1 = _GameWithDraggables();
      game1.onResize(Vector2.all(100));
      // should be ok
      await game1.add(DraggableComponent());

      final game2 = _GameWithoutDraggables();
      game2.onResize(Vector2.all(100));

      expect(
        () => game2.add(DraggableComponent()),
        throwsA(isA<AssertionError>()),
      );
    });

    test('can be dragged', () async {
      final game = _GameWithDraggables();
      game.onResize(Vector2.all(100));
      final component = DraggableComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;

      await game.add(component);
      // So component is added
      game.update(0.01);
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
    });

    test('when the game has camera zoom, can be dragged', () async {
      final game = _GameWithDraggables();
      game.onResize(Vector2.all(100));
      final component = DraggableComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;

      await game.add(component);
      game.camera.zoom = 1.5;
      // So component is added
      game.update(0.01);
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
    });

    test('when the game has a moved camera, dragging works', () async {
      final game = _GameWithDraggables();
      game.onResize(Vector2.all(100));
      final component = DraggableComponent()
        ..x = 50
        ..y = 50
        ..width = 10
        ..height = 10;

      await game.add(component);
      game.camera.zoom = 1.5;
      game.camera.snapTo(Vector2.all(50));
      // So component is added
      game.update(0.01);
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
    });
  });
}
