import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects/controllers/effect_controller.dart';
import 'package:flame/src/effects/transform2d_effect.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyEffect extends Transform2DEffect {
  _MyEffect(super.controller);

  @override
  void apply(double progress) {}
}

void main() {
  group('Transform2DEffect', () {
    flameGame.test(
      'onMount',
      (game) async {
        final component = PositionComponent();
        game.add(component);
        await game.ready();

        final effect = _MyEffect(EffectController(duration: 1));
        component.add(effect);
        game.update(0);
        expect(effect.transform, component.transform);

        final effect2 = _MyEffect(EffectController(duration: 1));
        expect(
          () => game.ensureAdd(effect2),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });
}
