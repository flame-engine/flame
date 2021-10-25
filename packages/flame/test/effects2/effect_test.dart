import 'package:flame/effects.dart';
import 'package:flame/src/components/component.dart';
import 'package:flame/src/effects2/effect.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

typedef VoidCallback = void Function();

class MyEffect extends Effect {
  MyEffect(FlameAnimationController controller) : super(controller);

  double x = -1;
  VoidCallback? onStartCallback;
  VoidCallback? onFinishCallback;

  @override
  void apply(double progress) {
    x = progress;
  }

  @override
  void reset() {
    super.reset();
    x = -1;
  }

  @override
  void onStart() {
    super.onStart();
    onStartCallback?.call();
  }

  @override
  void onFinish() {
    super.onFinish();
    onFinishCallback?.call();
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

    flameTest<FlameGame>(
      'removeOnFinish = true',
      createGame: () => FlameGame(),
      verify: (game) {
        final obj = Component();
        game.add(obj);
        final effect = MyEffect(StandardAnimationController(duration: 1));
        obj.add(effect);
        game.update(0);
        expect(obj.children.length, 1);

        expect(effect.removeOnFinish, true);
        expect(effect.isMounted, true);
        game.update(1);

        expect(effect.controller.completed, true);
        game.update(0);
        expect(effect.isMounted, false);
        expect(obj.children.length, 0);
      },
    );

    flameTest<FlameGame>(
      'removeOnFinish = false',
      createGame: () => FlameGame(),
      verify: (game) {
        final obj = Component();
        game.add(obj);
        final effect = MyEffect(StandardAnimationController(duration: 1));
        effect.removeOnFinish = false;
        obj.add(effect);
        game.update(0);
        expect(obj.children.length, 1);

        expect(effect.removeOnFinish, false);
        expect(effect.isMounted, true);

        // After the effect completes, it still remains mounted
        game.update(1);
        expect(effect.x, 1);
        expect(effect.controller.completed, true);
        game.update(0);
        expect(effect.isMounted, true);
        expect(obj.children.length, 1);

        // Even as more time is passing, the effect remains mounted and in
        // the completed state
        game.update(10);
        expect(effect.x, 1);
        expect(effect.isMounted, true);
        expect(effect.controller.completed, true);

        // However, once the effect is reset, it goes to its initial state
        effect.reset();
        expect(effect.x, -1);
        expect(effect.controller.completed, false);
        expect(effect.controller.started, false);

        game.update(0.5);
        expect(effect.x, 0.5);
        expect(effect.controller.started, true);
        expect(effect.controller.completed, false);

        // Now the effect completes once again, but still remains mounted
        game.update(0.5);
        expect(effect.controller.completed, true);
        expect(effect.x, 1);
        game.update(0);
        expect(effect.isMounted, true);
      },
    );

    test('removeOnFinish = error', () {
      final effect = MyEffect(
        StandardAnimationController(duration: 1, infinite: true),
      );
      expect(effect.controller.isInfinite, true);
      expect(effect.removeOnFinish, false);
      expect(() => effect.removeOnFinish = true, throwsAssertionError);
    });

    test('onStart & onFinish', () {
      var nStarted = 0;
      var nFinished = 0;
      final effect = MyEffect(StandardAnimationController(duration: 1))
        ..onStartCallback = () {
          nStarted++;
        }
        ..onFinishCallback = () {
          nFinished++;
        };

      effect.update(0);
      expect(effect.controller.started, true);
      expect(effect.x, 0);
      expect(nStarted, 1);
      expect(nFinished, 0);

      effect.update(0.5);
      expect(effect.controller.started, true);
      expect(effect.x, 0.5);
      expect(nStarted, 1);
      expect(nFinished, 0);

      effect.update(0.5);
      expect(effect.controller.started, true);
      expect(effect.controller.completed, true);
      expect(effect.x, 1);
      expect(nStarted, 1);
      expect(nFinished, 1);

      effect.update(0.5);
      expect(effect.x, 1);
      expect(nStarted, 1);
      expect(nFinished, 1);
    });
  });
}
