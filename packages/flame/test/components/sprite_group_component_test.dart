import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

enum _SpriteState {
  idle,
  running,
}

Future<void> main() async {
  // Generate a image
  final image = await generateImage();

  group('SpriteGroupComponent', () {
    test('returns the correct sprite according to its state', () {
      final sprite1 = Sprite(image);
      final sprite2 = Sprite(image);
      final component = SpriteGroupComponent<_SpriteState>(
        sprites: {
          _SpriteState.idle: sprite1,
          _SpriteState.running: sprite2,
        },
      );

      // No state was specified so nothing is playing
      expect(component.sprite, null);

      // Setting the idle state, we need to see the sprite1
      component.current = _SpriteState.idle;
      expect(component.sprite, sprite1);

      // Setting the running state, we need to see the sprite2
      component.current = _SpriteState.running;
      expect(component.sprite, sprite2);
    });
  });
}
