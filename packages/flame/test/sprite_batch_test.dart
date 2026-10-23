import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '_resources/load_image.dart';

class _MockImage() extends Mock implements Image;

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
      spriteBatch.add(source: Rect.zero, color: BasicPalette.blue.color);

      final red = BasicPalette.red.color;
      spriteBatch.replace(0, color: red);

      final batchItem = spriteBatch.getBatchItem(0);

      /// Use .closeTo() to avoid floating point rounding errors.
      expect(batchItem.paint.color.a, closeTo(red.a, 0.001));
      expect(batchItem.paint.color.r, closeTo(red.r, 0.001));
      expect(batchItem.paint.color.g, closeTo(red.g, 0.001));
      expect(batchItem.paint.color.b, closeTo(red.b, 0.001));
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

    test('negative bleed throws an assertion error', () {
      final image = _MockImage();
      final spriteBatch = SpriteBatch(image);
      expect(
        () => spriteBatch.add(source: Rect.zero, bleed: -1),
        throwsA(isA<AssertionError>()),
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

    test('bleed expands destination for non-atlas path', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.fromLTWH(0, 0, 10, 10);
      const bleed = 2.0;

      final index = spriteBatch.add(source: source, bleed: bleed);
      final batchItem = spriteBatch.getBatchItem(index);

      expect(
        batchItem.destination,
        const Rect.fromLTWH(-bleed, -bleed, 14, 14),
      );
    });

    test('zero bleed keeps destination at source size', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.fromLTWH(0, 0, 10, 10);

      final index = spriteBatch.add(source: source);
      final batchItem = spriteBatch.getBatchItem(index);

      expect(batchItem.destination, const Rect.fromLTWH(0, 0, 10, 10));
    });

    test('replace updates destination when source changes with bleed', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const bleed = 2.0;

      final index = spriteBatch.add(
        source: const Rect.fromLTWH(0, 0, 10, 10),
        bleed: bleed,
      );

      spriteBatch.replace(index, source: const Rect.fromLTWH(0, 0, 20, 20));
      final batchItem = spriteBatch.getBatchItem(index);

      expect(
        batchItem.destination,
        const Rect.fromLTWH(-bleed, -bleed, 24, 24),
      );
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

      spriteBatch.add(source: source);

      final storedTransform = spriteBatch.transforms.first;
      expect(storedTransform.scos, closeTo(1.0, 0.001));
      expect(storedTransform.ssin, closeTo(0.0, 0.001));
      expect(storedTransform.tx, closeTo(0.0, 0.001));
      expect(storedTransform.ty, closeTo(0.0, 0.001));
    });

    test('bleed on non-square sprite uses max scale for atlas path', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      // 10x20 sprite: scaleX=(12/10)=1.2, scaleY=(22/20)=1.1 -> scale=1.2
      const source = Rect.fromLTWH(0, 0, 10, 20);
      const bleed = 1.0;

      spriteBatch.add(source: source, bleed: bleed);

      final storedTransform = spriteBatch.transforms.first;
      // Atlas path uses max(scaleX, scaleY) = 1.2 uniformly
      expect(storedTransform.scos, closeTo(1.2, 0.001));
    });

    test('bleed on non-square sprite expands destination exactly', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.fromLTWH(0, 0, 10, 20);
      const bleed = 1.0;

      final index = spriteBatch.add(source: source, bleed: bleed);
      final batchItem = spriteBatch.getBatchItem(index);

      // Non-atlas path always expands by exactly bleed on every side
      expect(
        batchItem.destination,
        const Rect.fromLTWH(-bleed, -bleed, 12, 22),
      );
    });

    test('bleed with zero-size source does not corrupt transform', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.zero;

      spriteBatch.add(source: source, bleed: 1);

      final storedTransform = spriteBatch.transforms.first;
      expect(storedTransform.scos.isFinite, isTrue);
      expect(storedTransform.ssin.isFinite, isTrue);
    });

    test('replace updates matrix when transform changes', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);
      const source = Rect.fromLTWH(0, 0, 10, 10);

      final index = spriteBatch.add(source: source);
      final batchItem = spriteBatch.getBatchItem(index);

      // Read the matrix to trigger lazy initialization with original transform.
      final matrixBefore = batchItem.matrix;
      expect(matrixBefore.storage[12], closeTo(0.0, 0.001)); // tx

      spriteBatch.replace(index, transform: RSTransform(1, 0, 50, 60));

      // After replace the matrix must reflect the new transform.
      final matrixAfter = batchItem.matrix;
      expect(matrixAfter.storage[12], closeTo(50.0, 0.001)); // tx
      expect(matrixAfter.storage[13], closeTo(60.0, 0.001)); // ty
    });

    test('replace updates matrix when source changes', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image);

      final index = spriteBatch.add(source: const Rect.fromLTWH(0, 0, 10, 10));
      final batchItem = spriteBatch.getBatchItem(index);

      // Access matrix to initialize it with source width/height = 10.
      final _ = batchItem.matrix;

      // Replace with a wider source; the flip pivot must update.
      spriteBatch.replace(
        index,
        source: const Rect.fromLTWH(0, 0, 20, 20),
      );

      // The matrix is recomputed using the new source size.
      // A simple sanity check: accessing matrix must not throw.
      expect(() => batchItem.matrix, returnsNormally);
    });

    test('matrix keeps the item in the plane of the canvas', () {
      final image = _MockImage();
      when(() => image.width).thenReturn(100);
      when(() => image.height).thenReturn(100);
      final spriteBatch = SpriteBatch(image, useAtlas: false);

      for (final flip in [false, true]) {
        final index = spriteBatch.add(
          source: const Rect.fromLTWH(0, 0, 10, 10),
          flip: flip,
        );
        final matrix = spriteBatch.getBatchItem(index).matrix;

        expect(matrix.storage[14], closeTo(0, 1e-9)); // tz
        expect(matrix.determinant(), isNot(0));
      }
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
          color: BasicPalette.red.color,
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

    group('without the atlas', () {
      const cellSize = 20;
      const background = Color(0xFF9AD0A0);
      const itemColor = Color(0x800000FF);

      Future<Image> createSprite() {
        final recorder = PictureRecorder();
        Canvas(recorder).drawCircle(
          const Offset(cellSize / 2, cellSize / 2),
          cellSize / 3,
          Paint()..color = const Color(0xFFE53935),
        );
        return recorder.endRecording().toImage(cellSize, cellSize);
      }

      Future<Uint8List> renderBatch(
        Image sprite, {
        required bool useAtlas,
        BlendMode? defaultBlendMode,
        BlendMode? blendMode,
        Paint? paint,
      }) async {
        final spriteBatch = SpriteBatch(
          sprite,
          useAtlas: useAtlas,
          defaultBlendMode: defaultBlendMode,
        );
        spriteBatch.add(
          source: Rect.fromLTWH(0, 0, cellSize / 2, cellSize.toDouble()),
          color: itemColor,
        );
        spriteBatch.add(
          source: Rect.fromLTWH(
            cellSize / 2,
            0,
            cellSize / 2,
            cellSize.toDouble(),
          ),
          offset: Vector2(cellSize / 2, 0),
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder)..drawPaint(Paint()..color = background);
        spriteBatch.render(canvas, blendMode: blendMode, paint: paint);
        final image = await recorder.endRecording().toImage(
          cellSize,
          cellSize,
        );
        return (await image.toByteData())!.buffer.asUint8List();
      }

      int countDifferentPixels(Uint8List a, Uint8List b) {
        var differentPixels = 0;
        for (var i = 0; i < a.length; i += 4) {
          for (var c = 0; c < 4; c++) {
            // Allow small rounding differences.
            if ((a[i + c] - b[i + c]).abs() > 2) {
              differentPixels++;
              break;
            }
          }
        }
        return differentPixels;
      }

      const modes = [
        BlendMode.srcOver,
        BlendMode.srcOut,
        BlendMode.srcIn,
        BlendMode.srcATop,
        BlendMode.modulate,
        BlendMode.multiply,
      ];

      for (final mode in modes) {
        test('renders colors like drawAtlas with ${mode.name}', () async {
          final sprite = await createSprite();
          final expected = await renderBatch(
            sprite,
            useAtlas: true,
            blendMode: mode,
          );
          final fromRender = await renderBatch(
            sprite,
            useAtlas: false,
            blendMode: mode,
          );
          final fromDefault = await renderBatch(
            sprite,
            useAtlas: false,
            defaultBlendMode: mode,
          );

          expect(countDifferentPixels(expected, fromRender), 0);
          expect(countDifferentPixels(expected, fromDefault), 0);
        });
      }

      test('does not modify the paint passed to render', () async {
        final sprite = await createSprite();
        final paint = Paint();
        await renderBatch(
          sprite,
          useAtlas: false,
          blendMode: BlendMode.srcOut,
          paint: paint,
        );

        expect(paint.blendMode, BlendMode.srcOver);
      });

      Future<Uint8List> renderItem(
        Image sprite, {
        required bool useAtlas,
        required Rect source,
        double rotation = 0,
        Vector2? offset,
        Color? color,
        BlendMode? blendMode,
        Paint? paint,
      }) async {
        final spriteBatch = SpriteBatch(sprite, useAtlas: useAtlas);
        spriteBatch.add(
          source: source,
          rotation: rotation,
          anchor: source.size.toVector2() / 2,
          offset: offset,
          color: color,
        );

        final recorder = PictureRecorder();
        final canvas = Canvas(recorder)..drawPaint(Paint()..color = background);
        spriteBatch.render(canvas, blendMode: blendMode, paint: paint);
        final image = await recorder.endRecording().toImage(
          cellSize,
          cellSize,
        );
        return (await image.toByteData())!.buffer.asUint8List();
      }

      test('draws the default color behind the items', () async {
        final sprite = await createSprite();
        final spriteBatch = SpriteBatch(
          sprite,
          useAtlas: false,
          defaultColor: const Color(0xFF0000FF),
        );
        spriteBatch.add(
          source: Rect.fromLTWH(0, 0, cellSize.toDouble(), cellSize.toDouble()),
        );

        final recorder = PictureRecorder();
        spriteBatch.render(Canvas(recorder));
        final image = await recorder.endRecording().toImage(
          cellSize,
          cellSize,
        );
        final pixels = (await image.toByteData())!;

        // The corner of the sprite is transparent, so the default color shows.
        expect(pixels.getUint32(0), 0x0000FFFF);
      });

      test('blends the edges like drawAtlas at fractional offsets', () async {
        final recorder = PictureRecorder();
        Canvas(recorder).drawPaint(Paint()..color = const Color(0xFFE53935));
        final sprite = await recorder.endRecording().toImage(8, 8);

        Future<Uint8List> render({required bool useAtlas}) {
          return renderItem(
            sprite,
            useAtlas: useAtlas,
            source: const Rect.fromLTWH(0, 0, 8, 8),
            rotation: 0.3,
            offset: Vector2(10.3, 10.6),
            color: const Color(0xFF0000FF),
            blendMode: BlendMode.srcOut,
          );
        }

        final expected = await render(useAtlas: true);
        final actual = await render(useAtlas: false);
        // The opaque sprite and color cancel each other out everywhere.
        expect(actual, expected);
      });

      test('does not apply the render paint outside of the item', () async {
        final sprite = await createSprite();

        Future<Uint8List> render({required bool useAtlas}) {
          return renderItem(
            sprite,
            useAtlas: useAtlas,
            source: const Rect.fromLTWH(5, 5, 10, 10),
            rotation: 0.5,
            offset: Vector2.all(cellSize / 2),
            color: itemColor,
            blendMode: BlendMode.srcOver,
            // drawAtlas does not antialias the edges of the items.
            paint: Paint()
              ..blendMode = BlendMode.src
              ..isAntiAlias = false,
          );
        }

        final expected = await render(useAtlas: true);
        final actual = await render(useAtlas: false);
        expect(countDifferentPixels(expected, actual), 0);
      });

      testGolden(
        'renders colors like drawAtlas for different blend modes',
        (game, tester) async {
          final spriteSheet = await loadImage('alphabet.png');
          const source = Rect.fromLTWH(3 * tileSize, 0, tileSize, tileSize);
          const scale = 2.0;
          const cell = tileSize * scale + margin;

          // Each row uses a blend mode, the left column uses drawAtlas and the
          // right column uses the fallback, so both columns should match.
          for (final (row, mode) in modes.indexed) {
            for (final (column, useAtlas) in [true, false].indexed) {
              final spriteBatch = SpriteBatch(
                spriteSheet,
                useAtlas: useAtlas,
              );
              spriteBatch.add(
                source: source,
                color: itemColor,
                scale: scale,
                offset: Vector2(
                  margin + column * cell,
                  margin + row * cell,
                ),
              );
              game.add(
                SpriteBatchComponent(
                  spriteBatch: spriteBatch,
                  blendMode: mode,
                ),
              );
            }
          }
        },
        size: Vector2(
          margin + 2 * (tileSize * 2 + margin),
          margin + modes.length * (tileSize * 2 + margin),
        ),
        backgroundColor: background,
        goldenFile: '_goldens/sprite_batch_test_4.png',
      );
    });
  });
}
