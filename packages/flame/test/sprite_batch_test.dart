import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_resources/load_image.dart';

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

    testGolden(
      'can render a batch',
      (game) async {
        final spriteSheet = await loadImage('boom.png');
        final spriteBatch = SpriteBatch(spriteSheet);

        const source = Rect.fromLTWH(128 * 4.0, 128 * 4.0, 64, 128);

        spriteBatch.add(
          source: source,
          color: Colors.redAccent,
        );

        spriteBatch.add(
          source: source,
          offset: Vector2(100, 0),
        );

        game.add(
          SpriteBatchComponent(
            spriteBatch: spriteBatch,
            blendMode: BlendMode.srcOver,
          ),
        );
      },
      size: Vector2(300, 200),
      goldenFile: '_goldens/sprite_batch_test.png',
    );
  });
}
