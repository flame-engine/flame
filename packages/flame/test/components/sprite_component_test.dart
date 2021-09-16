import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() async {
  final image = await generateImage();

  group('SpriteComponent test', () {
    test('check sizing of SpriteComponent', () {
      expect(image.width, 1);
      expect(image.height, 1);

      final component1 = SpriteComponent.fromImage(image);
      expect(component1.size, Vector2(1, 1));

      final component2 = SpriteComponent.fromImage(image, size: Vector2(5, 10));
      expect(component2.size, Vector2(5, 10));

      final component3 = SpriteComponent.fromImage(
        image,
        srcSize: Vector2(4, 3),
      );
      expect(component3.size, Vector2(4, 3));

      final component4 = SpriteComponent.fromImage(
        image,
        size: Vector2(40, 30),
        srcSize: Vector2(4, 3),
      );
      expect(component4.size, Vector2(40, 30));

      final sprite = Sprite(image, srcSize: Vector2(2, 2));
      final component5 = SpriteComponent(sprite: sprite, size: Vector2(10, 10));
      expect(component5.size, Vector2(10, 10));

      final component6 = SpriteComponent(sprite: sprite);
      expect(component6.size, Vector2(2, 2));
    });
  });
}
