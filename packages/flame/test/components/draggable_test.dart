import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:test/test.dart';

class _GameHasDraggables extends FlameGame with HasDraggableComponents {}

class DraggableComponent extends PositionComponent with Draggable {
  bool hasStartedDragging = false;

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    hasStartedDragging = true;
    return true;
  }
}

void main() {
  final withDraggables = FlameTester(() => _GameHasDraggables());

  group('draggables test', () {
    withDraggables.test(
      'make sure they can be added to game with HasDraggables',
      (game) async {
        await game.add(DraggableComponent());
      },
    );

    flameGame.test(
      'make sure they cannot be added to invalid games',
      (game) async {
        const message =
            'Draggable Components can only be added to a FlameGame with '
            'HasDraggableComponents';

        expect(
          () => game.add(DraggableComponent()),
          throwsA(
            predicate(
              (e) => e is AssertionError && e.message == message,
            ),
          ),
        );
      },
    );

    withDraggables.test('can be dragged', (game) async {
      final component = DraggableComponent()
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
    });

    withDraggables.test('when the game has camera zoom, can be dragged',
        (game) async {
      final component = DraggableComponent()
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
    });

    withDraggables.test('when the game has a moved camera, dragging works',
        (game) async {
      final component = DraggableComponent()
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
    });
  });

  withDraggables.test('isDragged is changed', (game) async {
    final component = DraggableComponent()
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
    game.onDragCancel(1);
    expect(component.isDragged, false);
  });
}
