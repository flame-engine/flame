import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class _GameWithDraggables extends BaseGame with HasDraggableComponents {}

class _GameWithoutDraggables extends BaseGame {}

class DraggableComponent extends PositionComponent with Draggable {}

void main() {
  group('draggables test', () {
    test('make sure they cannot be added to invalid games', () async {
      final game1 = _GameWithDraggables();
      // should be ok
      await game1.add(DraggableComponent());

      final game2 = _GameWithoutDraggables();
      expect(
        () => game2.add(DraggableComponent()),
        isA<AssertionError>(),
      );
    });
  });
}
