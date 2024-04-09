import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockImage extends Mock implements Image {}

void main() {
  group('SpriteBatch', () {
    test('can add to the batch', () {
      final image = _MockImage();
      final spriteBatch = SpriteBatch(image);
      spriteBatch.add(source: Rect.zero);

      expect(spriteBatch.transforms, hasLength(1));
    });

    test('can replace the color of a batch', () {
      final image = _MockImage();
      final spriteBatch = SpriteBatch(image);
      spriteBatch.add(source: Rect.zero, color: Colors.blue);

      spriteBatch.replace(0, color: Colors.red);

      expect(spriteBatch.colors, hasLength(1));
      expect(spriteBatch.colors.first, Colors.red);
    });

    test('can replace the source of a batch', () {
      final image = _MockImage();
      final spriteBatch = SpriteBatch(image);
      spriteBatch.add(source: Rect.zero);

      spriteBatch.replace(0, source: const Rect.fromLTWH(1, 1, 1, 1));

      expect(spriteBatch.sources, hasLength(1));
      expect(spriteBatch.sources.first, const Rect.fromLTWH(1, 1, 1, 1));
    });

    test('can replace the transform of a batch', () {
      final image = _MockImage();
      final spriteBatch = SpriteBatch(image);
      spriteBatch.add(source: Rect.zero);

      spriteBatch.replace(0, transform: RSTransform(1, 1, 1, 1));

      expect(spriteBatch.transforms, hasLength(1));
      expect(
        spriteBatch.transforms.first,
        isA<RSTransform>()
            .having((t) => t.scos, 'scos', 1)
            .having((t) => t.ssin, 'ssin', 1)
            .having((t) => t.tx, 'tx', 1)
            .having((t) => t.ty, 'ty', 1),
      );
    });
  });
}
