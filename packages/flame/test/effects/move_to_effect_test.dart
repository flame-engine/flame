import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoveToEffect', () {
    testWithFlameGame('simple linear movement', (game) async {
      final component = PositionedComponent()..position = Vector2(3, 4);
      game.add(component);
      game.update(0);

      component.add(
        MoveToEffect(Vector2(5, -1), EffectController(duration: 1)),
      );
      game.update(0.5);
      expect(component.position.x, closeTo(3 * 0.5 + 5 * 0.5, 1e-15));
      expect(component.position.y, closeTo(4 * 0.5 + -1 * 0.5, 1e-15));
      game.update(0.5);
      expect(component.position.x, closeTo(5, 1e-15));
      expect(component.position.y, closeTo(-1, 1e-15));
    });
  });
}
