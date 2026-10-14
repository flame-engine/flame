import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

const _canvasWidth = 80;
const _canvasHeight = 48;

/// A 32x16 image where every pixel has a different color.
Future<Image> _gradientImage() {
  const width = 32;
  const height = 16;
  final pixels = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = 4 * (y * width + x);
      pixels[i] = x * 8;
      pixels[i + 1] = y * 16;
      pixels[i + 2] = 255 - x * 4;
      pixels[i + 3] = 255;
    }
  }
  return ImageExtension.fromPixels(pixels, width, height);
}

/// A 32x16 black and white checkerboard of 2x2 squares.
Future<Image> _checkerboardImage() {
  const width = 32;
  const height = 16;
  final pixels = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = 4 * (y * width + x);
      final value = (x ~/ 2 + y ~/ 2).isEven ? 255 : 0;
      pixels[i] = value;
      pixels[i + 1] = value;
      pixels[i + 2] = value;
      pixels[i + 3] = 255;
    }
  }
  return ImageExtension.fromPixels(pixels, width, height);
}

Future<Uint8List> _render(List<Component> components) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  for (final component in components) {
    component.renderTree(canvas);
  }
  final image = await recorder.endRecording().toImage(
    _canvasWidth,
    _canvasHeight,
  );
  return await image.pixelsInUint8();
}

int _maxDifference(Uint8List a, Uint8List b) {
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    final difference = (a[i] - b[i]).abs();
    if (difference > result) {
      result = difference;
    }
  }
  return result;
}

Future<void> _expectSameRendering(
  Component actual,
  Component expected,
) async {
  final difference = _maxDifference(
    await _render([actual]),
    await _render([expected]),
  );
  expect(difference, lessThanOrEqualTo(1));
}

class _WarpedSprite({
  super.sprite,
  super.position,
  super.size,
  super.bleed,
  super.paint,
}) extends SpriteComponent with HasWarpGrid;

class _WarpedRasterSprite({
  required super.baseSprite,
  super.images,
  super.position,
  super.size,
}) extends RasterSpriteComponent with HasWarpGrid;

class _WarpedSpriteGroup({
  super.sprites,
  super.current,
  super.position,
  super.size,
}) extends SpriteGroupComponent<int> with HasWarpGrid;

class _WarpedSpriteAnimation({
  super.animation,
  super.position,
  super.size,
}) extends SpriteAnimationComponent with HasWarpGrid;

class _WarpedSpriteAnimationGroup({
  super.animations,
  super.current,
  super.position,
  super.size,
}) extends SpriteAnimationGroupComponent<int> with HasWarpGrid;

_WarpedSprite _component(
  Sprite sprite, {
  WarpGrid? warpGrid,
  WarpInterpolation warpInterpolation = WarpInterpolation.bilinear,
  Vector2? position,
  double? bleed,
  Paint? paint,
}) {
  return _WarpedSprite(
      sprite: sprite,
      position: position ?? Vector2(4, 8),
      size: Vector2(64, 32),
      bleed: bleed,
      paint: paint,
    )
    ..warpGrid = warpGrid
    ..warpInterpolation = warpInterpolation;
}

/// A 2x2 grid with the center vertex moved towards the top-right.
WarpGrid _centerPull() {
  final grid = WarpGrid.identity(columns: 2, rows: 2);
  return grid.replacingDestinationPositions(
    grid.destinationPositions..[grid.vertexIndex(1, 1)] = Vector2(0.7, 0.3),
  );
}

Future<void> main() async {
  final image = await _gradientImage();

  group('SpriteComponent warping', () {
    for (final interpolation in WarpInterpolation.values) {
      group(interpolation.name, () {
        test('identity grids render like the unwarped sprite', () async {
          final sprite = Sprite(image);
          for (final grid in [
            WarpGrid.identity(),
            WarpGrid.identity(columns: 3, rows: 2),
          ]) {
            await _expectSameRendering(
              _component(
                sprite,
                warpGrid: grid,
                warpInterpolation: interpolation,
              ),
              _component(sprite),
            );
          }
        });

        test('identity grid on a sprite from a spritesheet', () async {
          final sprite = Sprite(
            image,
            srcPosition: Vector2(8, 4),
            srcSize: Vector2(16, 8),
          );
          await _expectSameRendering(
            _component(
              sprite,
              warpGrid: WarpGrid.identity(columns: 2, rows: 2),
              warpInterpolation: interpolation,
            ),
            _component(sprite),
          );
        });
      });
    }

    test('identity grid with bleed', () async {
      final sprite = Sprite(image);
      await _expectSameRendering(
        _component(sprite, warpGrid: WarpGrid.identity(), bleed: 16),
        _component(sprite, bleed: 16),
      );
    });

    test('identity grid at non-integer scales', () async {
      // With these scales some pixels sample the image exactly between two
      // texels, which every triangle of the mesh must round like
      // drawImageRect does.
      final sprite = Sprite(image);
      for (final bleed in [2.0, 6.0]) {
        await _expectSameRendering(
          _component(
            sprite,
            warpGrid: WarpGrid.identity(columns: 3, rows: 2),
            bleed: bleed,
          ),
          _component(sprite, bleed: bleed),
        );
      }
    });

    test('identity grid with opacity', () async {
      final sprite = Sprite(image);
      final warped = _component(sprite, warpGrid: WarpGrid.identity())
        ..opacity = 0.5;
      final unwarped = _component(sprite)..opacity = 0.5;
      await _expectSameRendering(warped, unwarped);
    });

    test('identity grid with a color filter', () async {
      final sprite = Sprite(image);
      final warped = _component(sprite, warpGrid: WarpGrid.identity())
        ..tint(const Color(0x8000FF00));
      final unwarped = _component(sprite)..tint(const Color(0x8000FF00));
      await _expectSameRendering(warped, unwarped);
    });

    test('applies the filters in the same order as drawImageRect', () async {
      final sprite = Sprite(await _checkerboardImage());
      for (final invertColors in [false, true]) {
        Paint filters() => Paint()
          ..colorFilter = const ColorFilter.linearToSrgbGamma()
          ..imageFilter = ImageFilter.blur(sigmaX: 1, sigmaY: 1)
          ..invertColors = invertColors;
        final warped = await _render([
          _component(sprite, warpGrid: WarpGrid.identity(), paint: filters()),
        ]);
        final unwarped = await _render([_component(sprite, paint: filters())]);

        // The edges differ, since an undistorted sprite repeats its border
        // pixels, so only the inside of the sprite is compared.
        var difference = 0;
        for (var y = 16; y < 32; y++) {
          for (var x = 12; x < 60; x++) {
            for (var c = 0; c < 4; c++) {
              final i = 4 * (y * _canvasWidth + x) + c;
              difference = max(difference, (warped[i] - unwarped[i]).abs());
            }
          }
        }
        expect(difference, lessThanOrEqualTo(1));
      }
    });

    test('destination positions are relative to the size', () async {
      final sprite = Sprite(image);
      final grid = WarpGrid.identity();
      final shifted = grid.replacingDestinationPositions([
        for (final p in grid.destinationPositions) p + Vector2(0.125, 0.25),
      ]);
      await _expectSameRendering(
        _component(sprite, warpGrid: shifted),
        _component(sprite, position: Vector2(4 + 8, 8 + 8)),
      );
    });

    test('source positions are relative to the sprite', () async {
      final sprite = Sprite(image, srcSize: Vector2(16, 16));
      final grid = WarpGrid.identity();
      final rightHalf = grid.replacingSourcePositions([
        for (final p in grid.sourcePositions) Vector2(0.5 + p.x / 2, p.y),
      ]);
      await _expectSameRendering(
        _component(sprite, warpGrid: rightHalf),
        _component(
          Sprite(image, srcPosition: Vector2(8, 0), srcSize: Vector2(8, 16)),
        ),
      );
    });

    test('components sharing a sprite are warped independently', () async {
      final sprite = Sprite(image);
      final src = sprite.src;
      final unwarped = await _render([_component(sprite)]);
      final pulled = await _render([
        _component(sprite, warpGrid: _centerPull()),
      ]);
      final smooth = await _render([
        _component(
          sprite,
          warpGrid: _centerPull(),
          warpInterpolation: WarpInterpolation.catmullRom,
        ),
      ]);

      expect(_maxDifference(pulled, unwarped), greaterThan(16));
      expect(_maxDifference(smooth, pulled), greaterThan(16));
      expect(sprite.src, src);
      expect(sprite.image.debugDisposed, isFalse);
    });

    test('caches the mesh and vertices', () async {
      final sprite = Sprite(image);
      final component = _component(sprite, warpGrid: _centerPull());

      await _render([component]);
      await _render([component]);
      final renderer = component.warpRenderer!;
      expect(renderer.meshBuilds, 1);
      expect(renderer.verticesBuilds, 1);

      component.size = Vector2(60, 30);
      await _render([component]);
      expect(renderer.meshBuilds, 1);
      expect(renderer.verticesBuilds, 2);

      sprite.srcSize = Vector2(16, 16);
      await _render([component]);
      expect(renderer.meshBuilds, 1);
      expect(renderer.verticesBuilds, 3);

      component.warpInterpolation = WarpInterpolation.catmullRom;
      await _render([component]);
      expect(renderer.meshBuilds, 2);
      expect(renderer.verticesBuilds, 4);

      // An equal but different grid is a new grid.
      component.warpGrid = _centerPull();
      await _render([component]);
      expect(renderer.meshBuilds, 3);
      expect(renderer.verticesBuilds, 5);
    });

    test('renders like a plain SpriteComponent without a grid', () async {
      final sprite = Sprite(image);
      await _expectSameRendering(
        _component(sprite, bleed: 3),
        SpriteComponent(
          sprite: sprite,
          position: Vector2(4, 8),
          size: Vector2(64, 32),
          bleed: 3,
        ),
      );
    });

    testWithFlameGame('works on SpriteComponent subclasses', (game) async {
      final baseSprite = Sprite(image);
      final images = Images();
      final warped = _WarpedRasterSprite(
        baseSprite: baseSprite,
        images: images,
        position: Vector2(4, 8),
        size: Vector2(64, 32),
      )..warpGrid = WarpGrid.identity(columns: 3, rows: 2);
      final plain = RasterSpriteComponent(
        baseSprite: baseSprite,
        images: images,
        position: Vector2(4, 8),
        size: Vector2(64, 32),
      );
      game.world.addAll([warped, plain]);
      await game.ready();

      expect(warped.sprite!.image, isNot(baseSprite.image));
      await _expectSameRendering(warped, plain);
      expect(warped.warpRenderer, isNotNull);

      warped.warpGrid = _centerPull();
      final difference = _maxDifference(
        await _render([warped]),
        await _render([plain]),
      );
      expect(difference, greaterThan(16));
    });

    test('works on SpriteGroupComponent', () async {
      final sprite = Sprite(image, srcSize: Vector2(16, 16));
      final warped = _WarpedSpriteGroup(
        sprites: {0: sprite},
        current: 0,
        position: Vector2(4, 8),
        size: Vector2(64, 32),
      )..warpGrid = WarpGrid.identity(columns: 3, rows: 2);

      await _expectSameRendering(warped, _component(sprite));
      expect(warped.warpRenderer, isNotNull);
    });

    test('works on SpriteAnimationComponent', () async {
      final frames = [
        Sprite(image, srcSize: Vector2(16, 16)),
        Sprite(image, srcPosition: Vector2(16, 0), srcSize: Vector2(16, 16)),
      ];
      final warped = _WarpedSpriteAnimation(
        animation: SpriteAnimation.spriteList(frames, stepTime: 1),
        position: Vector2(4, 8),
        size: Vector2(64, 32),
      )..warpGrid = WarpGrid.identity(columns: 3, rows: 2);

      await _expectSameRendering(warped, _component(frames[0]));
      warped.update(1);
      await _expectSameRendering(warped, _component(frames[1]));
      expect(warped.warpRenderer!.meshBuilds, 1);
    });

    test('works on SpriteAnimationGroupComponent', () async {
      final sprite = Sprite(image, srcSize: Vector2(16, 16));
      final warped = _WarpedSpriteAnimationGroup(
        animations: {
          0: SpriteAnimation.spriteList([sprite], stepTime: 1),
        },
        current: 0,
        position: Vector2(4, 8),
        size: Vector2(64, 32),
      )..warpGrid = WarpGrid.identity(columns: 3, rows: 2);

      await _expectSameRendering(warped, _component(sprite));
      expect(warped.warpRenderer, isNotNull);
    });

    test('drops the renderer when the grid is removed', () async {
      final sprite = Sprite(image);
      final component = _component(sprite, warpGrid: _centerPull());

      await _render([component]);
      expect(component.warpRenderer, isNotNull);

      component.warpGrid = null;
      expect(component.warpRenderer, isNull);
      await _expectSameRendering(component, _component(sprite));
    });

    testWithFlameGame('drops the renderer on removal', (game) async {
      final sprite = Sprite(image);
      final component = _component(sprite, warpGrid: _centerPull());
      game.world.add(component);
      await game.ready();

      await _render([component]);
      expect(component.warpRenderer, isNotNull);

      component.removeFromParent();
      await game.ready();
      expect(component.warpRenderer, isNull);
      expect(sprite.image.debugDisposed, isFalse);
    });

    group('with image eviction', () {
      Future<Images> evictingCache() async {
        return Images()
          ..gracePeriod = Duration.zero
          ..add('a', await _gradientImage())
          ..add('b', await _gradientImage());
      }

      testWithFlameGame('mounted images are not evicted', (game) async {
        final images = await evictingCache();
        final component = _component(
          Sprite(images.fromCache('a')),
          warpGrid: _centerPull(),
        );
        game.world.add(component);
        await game.ready();
        await _render([component]);

        images.evictUnused();
        expect(images.containsKey('a'), isTrue);
        expect(images.containsKey('b'), isFalse);
        await _render([component]);

        component.removeFromParent();
        await game.ready();
        expect(component.warpRenderer, isNull);
        images.evictUnused();
        expect(images.containsKey('a'), isFalse);
      });

      testWithFlameGame(
        'changing the sprite drops the renderer of the old image',
        (game) async {
          final images = await evictingCache();
          final a = images.fromCache('a');
          final component = _component(Sprite(a), warpGrid: _centerPull());
          game.world.add(component);
          await game.ready();
          await _render([component]);
          expect(component.warpRenderer, isNotNull);

          component.sprite = Sprite(images.fromCache('b'));
          expect(component.warpRenderer, isNull);
          images.evictUnused();
          expect(a.debugDisposed, isTrue);
          expect(images.containsKey('b'), isTrue);

          await _expectSameRendering(
            component,
            _component(component.sprite!, warpGrid: _centerPull()),
          );
        },
      );
    });
  });
}
