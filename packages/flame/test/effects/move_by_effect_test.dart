import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoveByEffect', () {
    test('simple linear motion', () {
      final game = FlameGame();
      game.onGameResize(Vector2(100, 100));
      final object = PositionComponent()..position = Vector2(3, 4);
      game.add(object);
      game.update(0);

      object.add(
        MoveByEffect(Vector2(5, -1), EffectController(duration: 1)),
      );
      game.update(0.5);
      expect(object.position.x, closeTo(3 + 2.5, 1e-15));
      expect(object.position.y, closeTo(4 + -0.5, 1e-15));
      game.update(0.5);
      expect(object.position.x, closeTo(3 + 5, 1e-15));
      expect(object.position.y, closeTo(4 + -1, 1e-15));
    });

    test('#to', () {
      final game = FlameGame();
      game.onGameResize(Vector2(100, 100));
      final object = PositionComponent()..position = Vector2(3, 4);
      game.add(object);
      game.update(0);

      object.add(
        MoveEffect.to(Vector2(5, -1), LinearEffectController(1)),
      );
      game.update(0.5);
      expect(object.position.x, closeTo(3 * 0.5 + 5 * 0.5, 1e-15));
      expect(object.position.y, closeTo(4 * 0.5 + -1 * 0.5, 1e-15));
      game.update(0.5);
      expect(object.position.x, closeTo(5, 1e-15));
      expect(object.position.y, closeTo(-1, 1e-15));
    });

    testWithFlameGame('custom target', (game) async {
      final rectComponent = _RectComponent()
        ..rect = const Rect.fromLTRB(10, 20, 50, 40)
        ..addToParent(game);
      rectComponent.add(
        MoveEffect.by(
          Vector2(3, -3),
          EffectController(duration: 1),
          target: _TopLeftCorner(rectComponent),
        ),
      );
      await game.ready();

      expect(rectComponent.rect, const Rect.fromLTRB(10, 20, 50, 40));
      game.update(0.5);
      expect(rectComponent.rect, const Rect.fromLTRB(11.5, 18.5, 50, 40));
      game.update(0.5);
      expect(rectComponent.rect, const Rect.fromLTRB(13, 17, 50, 40));
    });
  });
}

class _RectComponent extends Component {
  Rect rect = Rect.zero;
}

class _TopLeftCorner implements PositionProvider {
  _TopLeftCorner(this.target);
  _RectComponent target;

  @override
  Vector2 get position => Vector2(target.rect.left, target.rect.top);

  @override
  set position(Vector2 value) {
    final rect = target.rect;
    target.rect = Rect.fromLTRB(value.x, value.y, rect.right, rect.bottom);
  }
}
