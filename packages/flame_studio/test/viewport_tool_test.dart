import 'package:flame/components.dart';
import 'package:flame_studio/src/core/viewport_tool.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('selectableComponentsAt', () {
    testWithFlameGame('returns the components under the point, topmost first', (
      game,
    ) async {
      final bottom = PositionComponent(size: Vector2.all(100));
      final top = PositionComponent(size: Vector2.all(10), priority: 1);
      final elsewhere = PositionComponent(
        position: Vector2(50, 50),
        size: Vector2.all(10),
      );
      game.world.addAll([bottom, top, elsewhere]);
      await game.ready();

      // The world origin is at the center of the 800x600 canvas.
      expect(selectableComponentsAt(game, Vector2(405, 305)), [top, bottom]);
      expect(selectableComponentsAt(game, Vector2(455, 355)), [
        elsewhere,
        bottom,
      ]);
      expect(selectableComponentsAt(game, Vector2(10, 10)), isEmpty);
    });
  });

  group('pickNext', () {
    final first = PositionComponent();
    final second = PositionComponent();
    final third = PositionComponent();
    final candidates = [first, second, third];

    test('picks the topmost component', () {
      expect(pickNext(candidates, null), first);
      expect(pickNext(candidates, PositionComponent()), first);
    });

    test('cycles through the candidates', () {
      expect(pickNext(candidates, first), second);
      expect(pickNext(candidates, second), third);
      expect(pickNext(candidates, third), first);
    });

    test('picks nothing without candidates', () {
      expect(pickNext([], first), isNull);
    });
  });
}
