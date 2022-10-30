import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnchorByEffect', () {
    testWithFlameGame('simple AnchorEffect.by', (game) async {
      final component = PositionComponent(
        size: Vector2(100, 40),
        position: Vector2(12, 98),
        anchor: Anchor.center,
      );
      game.add(component);
      await game.ready();

      component.add(
        AnchorEffect.by(Vector2(0.3, 0.5), EffectController(duration: 1)),
      );
      for (var t = 0.0; t <= 1.0; t += 0.1) {
        expect(component.anchor.x, closeTo(0.5 + 0.3 * t, 1e-15));
        expect(component.anchor.y, closeTo(0.5 + 0.5 * t, 1e-15));
        game.update(0.1);
      }
    });

    testWithFlameGame('AnchorByEffect with explicit target', (game) async {
      final component = PositionComponent(anchor: Anchor.topCenter);
      game.add(component);
      game.add(
        AnchorByEffect(
          Vector2(-0.2, 0.6),
          EffectController(duration: 1),
          target: component,
        ),
      );
      await game.ready();

      for (var t = 0.0; t <= 1.0; t += 0.1) {
        expect(component.anchor.x, closeTo(0.5 - 0.2 * t, 1e-15));
        expect(component.anchor.y, closeTo(0.0 + 0.6 * t, 1e-15));
        game.update(0.1);
      }
    });
  });
}
