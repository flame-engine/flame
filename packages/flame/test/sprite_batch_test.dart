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

    const margin = 2.0;
    const tileSize = 6.0;

    testGolden(
      'can render a batch with blend mode',
      (game, tester) async {
        final spriteSheet = await loadImage('alphabet.png');
        final spriteBatch = SpriteBatch(spriteSheet);

        const source = Rect.fromLTWH(3 * tileSize, 0, tileSize, tileSize);

        spriteBatch.add(
          source: source,
          color: Colors.redAccent,
          offset: Vector2.all(margin),
        );

        spriteBatch.add(
          source: source,
          offset: Vector2(2 * margin + tileSize, margin),
        );

        game.add(
          SpriteBatchComponent(
            spriteBatch: spriteBatch,
            blendMode: BlendMode.srcOver,
          ),
        );
      },
      size: Vector2(3 * margin + 2 * tileSize, 2 * margin + tileSize),
      backgroundColor: const Color(0xFFFFFFFF),
      goldenFile: '_goldens/sprite_batch_test_1.png',
    );

    testGolden(
      'can render a batch without blend mode',
      (game, tester) async {
        final spriteSheet = await loadImage('alphabet.png');
        final spriteBatch = SpriteBatch(spriteSheet);

        const source = Rect.fromLTWH(3 * tileSize, 0, tileSize, tileSize);

        spriteBatch.add(
          source: source,
          offset: Vector2.all(margin),
        );

        spriteBatch.add(
          source: source,
          offset: Vector2(2 * margin + tileSize, margin),
        );

        game.add(
          SpriteBatchComponent(
            spriteBatch: spriteBatch,
          ),
        );
      },
      size: Vector2(3 * margin + 2 * tileSize, 2 * margin + tileSize),
      backgroundColor: const Color(0xFFFFFFFF),
      goldenFile: '_goldens/sprite_batch_test_2.png',
    );
  });
}
