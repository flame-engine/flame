import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_resources/load_image.dart';

void main() {
  group('Raster Sprite', () {
    group('rasterize sprite', () {
      testGolden(
        'still renders correctly',
        (game, tester) async {
          game.add(_MyRasterComponent()..position = Vector2.all(25));
        },
        goldenFile: '_goldens/sprite_test_1.png',
      );
    });

    test('adds the image to the cache', () async {
      final images = Images();
      expect(images.keys, isEmpty);

      final image = await loadImage('flame.png');
      images.add('flame.png', image);

      final baseSprite = await Sprite.load(
        'flame.png',
        images: images,
      );
      await baseSprite.rasterize(images: images);

      expect(images.keys, isNotEmpty);

      // A second rasterization with the same image should not add a new entry
      final secondBaseSprite = await Sprite.load(
        'flame.png',
        images: images,
      );
      await secondBaseSprite.rasterize(images: images);
      expect(images.keys, hasLength(2));
    });

    test(
      'resets srcPosition to zero on the rasterized sprite (regression #3902)',
      () async {
        final images = Images();
        final image = await loadImage('flame.png');
        images.add('flame.png', image);

        final atlasSprite = await Sprite.load(
          'flame.png',
          srcPosition: Vector2(10, 10),
          srcSize: Vector2(20, 20),
          images: images,
        );

        final rasterized = await atlasSprite.rasterize(images: images);

        expect(rasterized.srcPosition, Vector2.zero());
        expect(rasterized.srcSize, Vector2(20, 20));
        expect(rasterized.src, const Rect.fromLTWH(0, 0, 20, 20));

        // The cached branch must also produce a sprite with srcPosition (0,0)
        // — the cached image is already cropped to srcSize.
        final rasterizedAgain = await atlasSprite.rasterize(images: images);
        expect(rasterizedAgain.srcPosition, Vector2.zero());
        expect(rasterizedAgain.src, const Rect.fromLTWH(0, 0, 20, 20));
      },
    );

    group('when using a custom cache key', () {
      test('adds the image to the cache with the custom key', () async {
        final images = Images();
        expect(images.keys, isEmpty);

        final image = await loadImage('flame.png');
        images.add('flame.png', image);

        final baseSprite = await Sprite.load(
          'flame.png',
          images: images,
        );
        const customKey = 'custom_key';
        await baseSprite.rasterize(cacheKey: customKey, images: images);

        expect(images.keys, contains(customKey));

        // A second rasterization with the same image and custom key should not
        // add a new entry
        await baseSprite.rasterize(cacheKey: customKey, images: images);
        expect(images.keys, hasLength(2));
      });
    });
  });
}

class _MyRasterComponent extends PositionComponent {
  _MyRasterComponent() : super(size: Vector2(200, 400));
  late final Sprite sprite;

  @override
  Future<void> onLoad() async {
    final baseSprite = Sprite(await loadImage('flame.png'));
    sprite = await baseSprite.rasterize();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = const Color(0xffffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Expected: sprite is rendered in the center of the rect
    sprite.render(canvas, position: size / 2, anchor: Anchor.center);
  }
}
