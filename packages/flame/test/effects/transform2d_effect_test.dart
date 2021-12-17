import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/transform2d_effect.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyEffect extends Transform2DEffect {
  _MyEffect(EffectController controller) : super(controller);
}

void main() {
  group('Transform2DEffect', () {
    flameGame.test(
      'onMount',
      (game) {
        final component = PositionComponent();
        game.add(component);
        game.update(0);

        final effect = _MyEffect(EffectController(duration: 1));
        component.add(effect);
        game.update(0);
        expect(effect.transform, component.transform);

        final effect2 = _MyEffect(EffectController(duration: 1));
        expect(
          () async => game.add(effect2),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });
}
