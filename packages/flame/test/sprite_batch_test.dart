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
      final index = spriteBatch.add(source: Rect.zero);

      expect(spriteBatch.getBatchItem(index), isNotNull);
    });

    test('can replace the color of a batch', () {
      final image = _MockImage();
      final spriteBatch = SpriteBatch(image);
      spriteBatch.add(source: Rect.zero, color: Colors.blue);

      spriteBatch.replace(0, color: Colors.red);

      final batchItem = spriteBatch.getBatchItem(0);

      /// Use .closeTo() to avoid floating point rounding errors.
      expect(batchItem.paint.color.a, closeTo(Colors.red.a, 0.001));
      expect(batchItem.paint.color.r, closeTo(Colors.red.r, 0.001));
      expect(batchItem.paint.color.g, closeTo(Colors.red.g, 0.001));
      expect(batchItem.paint.color.b, closeTo(Colors.red.b, 0.001));
    });

    test('can replace the source of a batch', () {
      final image = _MockImage();
      final spriteBatch = SpriteBatch(image);
      spriteBatch.add(source: Rect.zero);

      spriteBatch.replace(0, source: const Rect.fromLTWH(1, 1, 1, 1));
      final batchItem = spriteBatch.getBatchItem(0);

      expect(batchItem.source, const Rect.fromLTWH(1, 1, 1, 1));
    });

    test('can replace the transform of a batch', () {
      final image = _MockImage();
      final spriteBatch = SpriteBatch(image);
      spriteBatch.add(source: Rect.zero);

      spriteBatch.replace(0, transform: RSTransform(1, 1, 1, 1));
      final batchItem = spriteBatch.getBatchItem(0);

      expect(
        batchItem.transform,
        isA<RSTransform>()
            .having((t) => t.scos, 'scos', 1)
            .having((t) => t.ssin, 'ssin', 1)
            .having((t) => t.tx, 'tx', 1)
            .having((t) => t.ty, 'ty', 1),
      );
    });

    test('can add batch item with bleed', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.fromLTWH(0, 0, 10, 10);
      const bleed = 2.0;

      final index = spriteBatch.add(
        source: source,
        bleed: bleed,
      );
      final batchItem = spriteBatch.getBatchItem(index);

      expect(batchItem.bleed, bleed);
    });

    test('bleed scales the transform correctly', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.fromLTWH(0, 0, 10, 10);
      const bleed = 1.0;
      // Expected scale: (10 + 2*1) / 10 = 1.2
      const expectedScale = 1.2;

      spriteBatch.add(
        source: source,
        bleed: bleed,
      );

      // The stored transform should be scaled by the bleed factor
      final storedTransform = spriteBatch.transforms.first;
      expect(storedTransform.scos, closeTo(expectedScale, 0.001));
      expect(storedTransform.ssin, closeTo(0.0, 0.001));
    });

    test('bleed is preserved when replacing transform', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.fromLTWH(0, 0, 10, 10);
      const bleed = 2.0;

      final index = spriteBatch.add(
        source: source,
        bleed: bleed,
      );

      // Replace the transform - bleed should be re-applied
      spriteBatch.replace(index, transform: RSTransform(2, 0, 5, 5));

      final batchItem = spriteBatch.getBatchItem(index);
      expect(batchItem.bleed, bleed);

      // The new transform should have bleed applied
      // Original: scos=2, with bleed scale 1.4 -> scos=2.8
      const expectedScale = (10 + 2 * bleed) / 10; // 1.4
      final storedTransform = spriteBatch.transforms.first;
      expect(storedTransform.scos, closeTo(2 * expectedScale, 0.001));
    });

    test('zero bleed does not affect transform', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.fromLTWH(0, 0, 10, 10);

      spriteBatch.add(
        source: source,
        bleed: 0,
      );

      final storedTransform = spriteBatch.transforms.first;
      expect(storedTransform.scos, closeTo(1.0, 0.001));
      expect(storedTransform.ssin, closeTo(0.0, 0.001));
      expect(storedTransform.tx, closeTo(0.0, 0.001));
      expect(storedTransform.ty, closeTo(0.0, 0.001));
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

    testGolden(
      'can render a batch with bleed',
      (game, tester) async {
        final spriteSheet = await loadImage('alphabet.png');
        final spriteBatch = SpriteBatch(spriteSheet);

        // Source is a single tile - we want to see if bleed expands the render
        const source = Rect.fromLTWH(3 * tileSize, 0, tileSize, tileSize);
        const bleed = 1.0;

        // Add sprite without bleed (left)
        spriteBatch.add(
          source: source,
          offset: Vector2.all(margin),
          scale: 2.0,
        );

        // Add sprite with bleed (right) - should appear slightly larger
        spriteBatch.add(
          source: source,
          offset: Vector2(2 * margin + tileSize * 2 + 4, margin),
          scale: 2.0,
          bleed: bleed,
        );

        game.add(
          SpriteBatchComponent(
            spriteBatch: spriteBatch,
          ),
        );
      },
      size: Vector2(4 * margin + 4 * tileSize + 4, 3 * margin + 2 * tileSize),
      backgroundColor: const Color(0xFFFFFFFF),
      goldenFile: '_goldens/sprite_batch_test_3.png',
    );
  });
}
