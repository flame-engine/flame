import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlowEffect', () {
    testWithFlameGame('can apply to component having HasPaint', (game) async {
      final component = _PaintComponent();

      await game.ensureAdd(component);

      await component.add(
        GlowEffect(1, EffectController(duration: 1)),
      );

      game.update(0);

      expect(component.children.length, 1);
      expect(component.paint.maskFilter, isNotNull);

      expect(
        component.paint.maskFilter.toString(),
        'MaskFilter.blur(BlurStyle.outer, 0.0)',
      );

      game.update(1);

      expect(
        component.paint.maskFilter.toString(),
        'MaskFilter.blur(BlurStyle.outer, 1.0)',
      );
    });
  });
}

class _PaintComponent extends Component with HasPaint {}
