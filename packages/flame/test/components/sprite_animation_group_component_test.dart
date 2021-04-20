import 'package:flame/components.dart';
import 'package:test/test.dart';

import '../util/mock_image.dart';

enum AnimationState {
  idle,
  running,
}

void main() async {
  // Generate a image
  final image = await generateImage();

  group('SpriteAnimationGroupComponent test', () {
    test('returns the correct animation according to its state', () {
      final animation1 = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
      );
      final animation2 = SpriteAnimation.spriteList(
        [
          Sprite(image),
          Sprite(image),
        ],
        stepTime: 1,
      );
      final component = SpriteAnimationGroupComponent<AnimationState>(
        animations: {
          AnimationState.idle: animation1,
          AnimationState.running: animation2,
        },
      );

      // No state was specified so nothing is playing
      expect(component.animation, null);

      // Setting the idle state, we need to see the animation1
      component.current = AnimationState.idle;
      expect(component.animation, animation1);

      // Setting the running state, we need to see the animation2
      component.current = AnimationState.running;
      expect(component.animation, animation2);
    });
  });
}
