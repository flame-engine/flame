import 'package:flame/src/image_composition.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockImage extends Mock implements Image {}

void main() {
  group('ImageComposition', () {
    test('breaks assertion when adding an invalid portion', () {
      final composition = ImageComposition();
      final image = MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);

      final invalidRects = [
        const Rect.fromLTWH(-10, 10, 10, 10),
        const Rect.fromLTWH(10, -10, 10, 10),
        const Rect.fromLTWH(110, 10, 10, 10),
        const Rect.fromLTWH(0, 110, 10, 10),
        const Rect.fromLTWH(0, 0, 110, 110),
        const Rect.fromLTWH(20, 0, 90, 10),
        const Rect.fromLTWH(0, 20, 90, 90),
        const Rect.fromLTWH(0, 0, 190, 90),
        const Rect.fromLTWH(0, 0, 90, 190),
      ];

      invalidRects.forEach((rect) {
        expect(
          () => composition.add(image, Vector2.zero(), source: rect),
          failsAssert('Source rect should fit within the image'),
        );
      });
    });
  });
}
