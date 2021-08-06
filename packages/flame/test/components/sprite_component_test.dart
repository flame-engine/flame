import 'package:flame/components.dart';
import 'package:test/test.dart';

import '../../lib/src/test_helpers/mock_image.dart';

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
    });
  });
}
