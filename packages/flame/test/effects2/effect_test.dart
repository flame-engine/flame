
import 'package:flame/effects.dart';
import 'package:flame/src/effects2/effect.dart';
import 'package:flutter_test/flutter_test.dart';

class MyEffect extends Effect {
  MyEffect(FlameAnimationController controller) : super(controller);

  double x = -1;

  @override
  void apply(double progress) {
    x = progress;
  }

  @override
  void reset() {
    super.reset();
    x = -1;
  }
}

void main() {
  group('Effect', () {
    test('Pause & Resume', () {
      final effect = MyEffect(StandardAnimationController(duration: 10));
      expect(effect.x, -1);
      expect(effect.isPaused, false);

      effect.update(0);
      expect(effect.x, 0);

      effect.update(1);
      expect(effect.x, closeTo(0.1, 1e-15));

      effect.update(2);
      expect(effect.x, closeTo(0.3, 1e-15));

      effect.pause();
      effect.update(5);
      effect.update(2);
      expect(effect.x, closeTo(0.3, 1e-15));

      effect.resume();
      effect.update(1);
      expect(effect.x, closeTo(0.4, 1e-15));

      effect.pause();
      effect.update(1000);
      expect(effect.isPaused, true);

      effect.reset();
      expect(effect.isPaused, false);
      expect(effect.x, -1);

      effect.update(5);
      expect(effect.x, closeTo(0.5, 1e-15));

      effect.update(5);
      expect(effect.x, closeTo(1, 1e-15));
    });
  });
}