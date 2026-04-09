import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flame_texturepacker/experimental.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CompositeAtlas Logic Coverage', () {
    test('Throws StateError on empty bake requests', () async {
      expect(
        () => CompositeAtlas.bake([]),
        throwsStateError,
      );
    });

    test('Packing produces valid atlas', () async {
      final img1 = await createSolidImage(32, 32, const ui.Color(0xFFFF0000));
      final img2 = await createSolidImage(64, 32, const ui.Color(0xFF00FF00));

      final atlas = await CompositeAtlas.bake(
        [
          ImageBakeRequest(img1, name: 'red'),
          ImageBakeRequest(img2, name: 'green'),
        ],
      );

      expect(atlas.findSpriteByName('red'), isNotNull);
      expect(atlas.findSpriteByName('green'), isNotNull);
      // Atlas should be at least large enough to fit them
      expect(atlas.image.width, greaterThanOrEqualTo(64));
      expect(atlas.image.height, greaterThanOrEqualTo(32));
    });

    test('allowRotation: false respects constraints', () async {
      // Create a tall thin image that would fit better if rotated in a wide atlas
      final tall = await createSolidImage(10, 100, const ui.Color(0xFF0000FF));

      final atlas = await CompositeAtlas.bake(
        [ImageBakeRequest(tall, name: 'tall')],
        allowRotation: false,
        maxAtlasWidth: 50, // Force narrow atlas
      );

      final sprite = atlas.findSpriteByName('tall');
      expect(sprite, isNotNull);
      // Even if it fits better rotated, rotate should be false
      expect(sprite!.region.rotate, isFalse);
    });

    test('trim: false preserves full source dimensions', () async {
      // Create image with huge transparent borders
      final img = await createTransparentBorderedImage(10, 10, 50, 50);

      // 1. With trim: true
      final atlasTrimmed = await CompositeAtlas.bake(
        [ImageBakeRequest(img, name: 'sprite')],
        trim: true,
      );
      final spriteTrimmed = atlasTrimmed.findSpriteByName('sprite')!;
      // Should be trimmed back to ~10x10
      expect(spriteTrimmed.region.width, closeTo(10, 1.0));

      // 2. With trim: false
      final atlasFull = await CompositeAtlas.bake(
        [ImageBakeRequest(img, name: 'sprite')],
        trim: false,
      );
      final spriteFull = atlasFull.findSpriteByName('sprite')!;
      // Should preserve full 50x50 size
      expect(spriteFull.region.width, equals(50.0));
    });

    test('nameTransformer modifies keys correctly', () async {
      final img = await createSolidImage(10, 10, const ui.Color(0xFFFF00FF));

      final atlas = await CompositeAtlas.bake(
        [
          ImageBakeRequest(
            img,
            name: 'hero',
            nameTransformer: (name) => 'transformed_$name',
          ),
        ],
      );

      expect(atlas.findSpriteByName('hero'), isNull);
      expect(atlas.findSpriteByName('transformed_hero'), isNotNull);
    });

    test('Deduplication of identical images with different names', () async {
      final img = await createSolidImage(16, 16, const ui.Color(0xFFABCDEF));

      // Two different requests using the same pixels
      final atlas = await CompositeAtlas.bake([
        ImageBakeRequest(img, name: 'one'),
        ImageBakeRequest(img, name: 'two'),
      ]);

      final s1 = (atlas as TexturePackerAtlas).findSpriteByName('one')!;
      final s2 = (atlas as TexturePackerAtlas).findSpriteByName('two')!;

      // They should share the same slot in the texture
      expect(s1.region.left, equals(s2.region.left));
      expect(s1.region.top, equals(s2.region.top));
    });

    test('Fast Path (GDX source) vs Alpha Analysis Path', () async {
      final img = await createSolidImage(32, 32, const ui.Color(0xFF112233));

      // We'll simulate a GDX source by creating a TexturePackerSprite manually
      final bakedGdx = await CompositeAtlas.bake([
        ImageBakeRequest(img, name: 'gdx_like'),
      ]);
      final gdxSprite = (bakedGdx as TexturePackerAtlas).findSpriteByName(
        'gdx_like',
      )!;

      // Bake a request that uses this "GDX" sprite as source
      final finalAtlas = await CompositeAtlas.bake([
        AtlasBakeRequest(TexturePackerAtlas([gdxSprite])),
      ]);

      // Since the source was already a TexturePackerSprite and no decorator is used,
      // it should take the "Fast Path" (direct copy without re-scanning alpha).
      expect(finalAtlas.findSpriteByName('gdx_like'), isNotNull);
    });
  });
}

/// Helper to create a solid color ui.Image
Future<ui.Image> createSolidImage(int w, int h, ui.Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(color, ui.BlendMode.src);
  return recorder.endRecording().toImage(w, h);
}

/// Helper to create an image with content centered in a larger transparent area
Future<ui.Image> createTransparentBorderedImage(
  int contentW,
  int contentH,
  int fullW,
  int fullH,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  final paint = ui.Paint()..color = const ui.Color(0xFFFF0000);
  final rect = ui.Rect.fromCenter(
    center: ui.Offset(fullW / 2, fullH / 2),
    width: contentW.toDouble(),
    height: contentH.toDouble(),
  );
  canvas.drawRect(rect, paint);

  return recorder.endRecording().toImage(fullW, fullH);
}
