import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('PictureExtension', () {
    test('toImageSafe calls dispose on the Picture', () async {
      final picture = MockPicture();

      // Mock the picture.toImage call to return a test image
      when(() => picture.toImage(1, 1)).thenAnswer((_) => createTestImage());

      await picture.toImageSafe(1, 1);

      // Verify that dispose has been called on picture
      // (which is the point of toImageSafe)
      verify(picture.dispose).called(1);
    });
  });
}

class MockPicture extends Mock implements Picture {}
