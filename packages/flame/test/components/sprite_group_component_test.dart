import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

enum SpriteState {
  idle,
  running,
}

void main() async {
  // Generate a image
  final image = await generateImage();

  group('SpriteGroupComponent test', () {
    test('returns the correct sprite according to its state', () {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image);
      final component = SpriteGroupComponent<SpriteState>(
        sprites: {
          SpriteState.idle: sprite1,
          SpriteState.running: sprite2,
        },
      );

      // No state was specified so nothing is playing
      expect(component.sprite, null);

      // Setting the idle state, we need to see the sprite1
      component.current = SpriteState.idle;
      expect(component.sprite, sprite1);

      // Setting the running state, we need to see the sprite2
      component.current = SpriteState.running;
      expect(component.sprite, sprite2);
    });
  });
}
