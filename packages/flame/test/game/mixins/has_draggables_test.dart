import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _GameWithDraggables extends FlameGame with HasDraggables {
  int handledOnDragStart = 0;
  int handledOnDragUpdate = 0;
  int handledOnDragCancel = 0;

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    if (info.handled) {
      handledOnDragStart++;
    }
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    if (info.handled) {
      handledOnDragUpdate++;
    }
  }

  @override
  void onDragCancel(int pointerId) {
    super.onDragCancel(pointerId);
    handledOnDragCancel++;
  }
}

class _DraggableComponent extends PositionComponent with Draggable {
  _DraggableComponent() : super(size: Vector2.all(100));

  @override
  bool onDragCancel() {
    return true;
  }

  @override
  bool onDragStart(DragStartInfo info) {
    info.handled = true;
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    info.handled = true;
    return true;
  }
}

void main() {
  final withDraggables = FlameTester(_GameWithDraggables.new);

  group('HasDraggables', () {
    testWithGame<_GameWithDraggables>(
      'make sure Draggables can be added to valid games',
      _GameWithDraggables.new,
      (game) async {
        await game.ensureAdd(_DraggableComponent());
      },
    );

    testWithFlameGame(
      'make sure Draggables cannot be added to invalid games',
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

    withDraggables.testGameWidget(
      'drag correctly registered handled event',
      setUp: (game, _) async {
        await game.ensureAdd(_DraggableComponent());
      },
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(10, 10), const Offset(90, 90));
        expect(game.handledOnDragStart, 1);
        expect(game.handledOnDragUpdate > 0, isTrue);
        expect(game.handledOnDragCancel, 0);
      },
    );

    withDraggables.testGameWidget(
      'drag outside of component is not registered as handled',
      setUp: (game, _) async {
        await game.ensureAdd(_DraggableComponent());
      },
      verify: (game, tester) async {
        await tester.dragFrom(const Offset(110, 110), const Offset(120, 120));
        expect(game.handledOnDragStart, 0);
        expect(game.handledOnDragUpdate, 0);
        expect(game.handledOnDragCancel, 0);
      },
    );
  });
}
