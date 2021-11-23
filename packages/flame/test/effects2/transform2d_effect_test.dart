import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects2/controllers/effect_controller.dart';
import 'package:flame/src/effects2/controllers/standard_controller.dart';
import 'package:flame/src/effects2/transform2d_effect.dart';
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
        final obj = PositionComponent();
        game.add(obj);
        game.update(0);

        final effect = _MyEffect(standardController(duration: 1));
        obj.add(effect);
        game.update(0);
        expect(effect.target, obj.transform);

        final effect2 = _MyEffect(standardController(duration: 1));
        expect(
          () async => game.add(effect2),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });
}
