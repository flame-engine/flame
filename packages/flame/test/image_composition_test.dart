import 'dart:ui';

import 'package:flame/image_composition.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:flame/extensions.dart';

class MockImage extends Mock implements Image {}

void main() {
  group('ImageComposition', () {
    group('add', () {
      test('breaks assertion when adding an invalid portion', () {
        final image = MockImage();
        final composition = ImageComposition();

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

        invalidRects.forEach((r) {
          expect(
            () => composition.add(image, Vector2.zero(), source: r),
            throwsA(isA<AssertionError>()),
          );
        });
      });
    });
  });
}
