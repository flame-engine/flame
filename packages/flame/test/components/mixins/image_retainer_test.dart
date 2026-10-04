import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _RetainingComponent({required this.images})
    extends Component
    with ImageRetainer {
  List<Image> images;

  @override
  Iterable<Image> get retainedImages => images;

  void setImages(List<Image> value) {
    images = value;
    updateRetainedImages();
  }
}

void main() {
  group('ImageRetainer', () {
    late Images cache;
    late Image a;
    late Image b;

    setUp(() async {
      cache = Images();
      a = await generateImage();
      b = await generateImage(2, 2);
      cache
        ..add('a', a)
        ..add('b', b);
    });

    testWithFlameGame('retains images while mounted', (game) async {
      final component = _RetainingComponent(images: [a]);
      expect(cache.retainCount('a'), 0);

      await game.ensureAdd(component);
      expect(cache.retainCount('a'), 1);

      component.removeFromParent();
      await game.ready();
      expect(cache.retainCount('a'), 0);
    });

    testWithFlameGame('retains again when re-added', (game) async {
      final component = _RetainingComponent(images: [a]);
      await game.ensureAdd(component);
      component.removeFromParent();
      await game.ready();

      await game.ensureAdd(component);
      expect(cache.retainCount('a'), 1);
    });

    testWithFlameGame('retains each image once', (game) async {
      final component = _RetainingComponent(images: [a, a, a]);
      await game.ensureAdd(component);
      expect(cache.retainCount('a'), 1);

      component.removeFromParent();
      await game.ready();
      expect(cache.retainCount('a'), 0);
    });

    testWithFlameGame('swaps retained images when updated', (game) async {
      final component = _RetainingComponent(images: [a]);
      await game.ensureAdd(component);

      component.setImages([b]);
      expect(cache.retainCount('a'), 0);
      expect(cache.retainCount('b'), 1);

      component.removeFromParent();
      await game.ready();
      expect(cache.retainCount('b'), 0);
    });

    testWithFlameGame('does nothing when updated before mount', (game) async {
      final component = _RetainingComponent(images: [a]);
      component.setImages([b]);
      expect(cache.retainCount('a'), 0);
      expect(cache.retainCount('b'), 0);

      await game.ensureAdd(component);
      expect(cache.retainCount('b'), 1);
    });

    testWithFlameGame('retains clones through the game cache', (game) async {
      game.images = cache;
      final clone = a.clone();
      final component = _RetainingComponent(images: [clone]);

      await game.ensureAdd(component);
      expect(cache.retainCount('a'), 1);

      component.removeFromParent();
      await game.ready();
      expect(cache.retainCount('a'), 0);
      clone.dispose();
    });

    testWithFlameGame('ignores images that belong to no cache', (game) async {
      final loose = await generateImage();
      final component = _RetainingComponent(images: [loose]);

      await game.ensureAdd(component);
      component.removeFromParent();
      await game.ready();
      loose.dispose();
    });

    testWithFlameGame('survives the image being cleared while retained', (
      game,
    ) async {
      final component = _RetainingComponent(images: [a]);
      await game.ensureAdd(component);
      cache.clear('a');

      component.removeFromParent();
      await game.ready();
      expect(cache.retainCount('a'), 0);
    });

    group('components', () {
      testWithFlameGame('SpriteComponent', (game) async {
        final component = SpriteComponent.fromImage(a);
        await game.ensureAdd(component);
        expect(cache.retainCount('a'), 1);

        component.sprite = Sprite(b);
        expect(cache.retainCount('a'), 0);
        expect(cache.retainCount('b'), 1);

        component.removeFromParent();
        await game.ready();
        expect(cache.retainCount('b'), 0);
      });

      testWithFlameGame('SpriteAnimationComponent', (game) async {
        final component = SpriteAnimationComponent(
          animation: SpriteAnimation.spriteList(
            [Sprite(a), Sprite(b)],
            stepTime: 1,
          ),
        );
        await game.ensureAdd(component);
        expect(cache.retainCount('a'), 1);
        expect(cache.retainCount('b'), 1);

        component.animation = SpriteAnimation.spriteList(
          [Sprite(b)],
          stepTime: 1,
        );
        expect(cache.retainCount('a'), 0);
        expect(cache.retainCount('b'), 1);

        component.removeFromParent();
        await game.ready();
        expect(cache.retainCount('b'), 0);
      });

      testWithFlameGame('SpriteGroupComponent', (game) async {
        final component = SpriteGroupComponent<int>(
          sprites: {0: Sprite(a), 1: Sprite(b)},
          current: 0,
        );
        await game.ensureAdd(component);
        expect(cache.retainCount('a'), 1);
        expect(cache.retainCount('b'), 1);

        component.updateSprite(1, Sprite(a));
        expect(cache.retainCount('a'), 1);
        expect(cache.retainCount('b'), 0);

        component.sprites = {0: Sprite(b)};
        component.current = 0;
        expect(cache.retainCount('a'), 0);
        expect(cache.retainCount('b'), 1);

        component.removeFromParent();
        await game.ready();
        expect(cache.retainCount('b'), 0);
      });

      testWithFlameGame('SpriteAnimationGroupComponent', (game) async {
        final component = SpriteAnimationGroupComponent<int>(
          animations: {
            0: SpriteAnimation.spriteList([Sprite(a)], stepTime: 1),
            1: SpriteAnimation.spriteList([Sprite(b)], stepTime: 1),
          },
          current: 0,
        );
        await game.ensureAdd(component);
        expect(cache.retainCount('a'), 1);
        expect(cache.retainCount('b'), 1);

        component.animations = {
          0: SpriteAnimation.spriteList([Sprite(b)], stepTime: 1),
        };
        expect(cache.retainCount('a'), 0);
        expect(cache.retainCount('b'), 1);

        component.removeFromParent();
        await game.ready();
        expect(cache.retainCount('b'), 0);
      });

      testWithFlameGame('SpriteBatchComponent', (game) async {
        final component = SpriteBatchComponent(spriteBatch: SpriteBatch(a));
        await game.ensureAdd(component);
        expect(cache.retainCount('a'), 1);

        component.spriteBatch = SpriteBatch(b);
        expect(cache.retainCount('a'), 0);
        expect(cache.retainCount('b'), 1);

        component.removeFromParent();
        await game.ready();
        expect(cache.retainCount('b'), 0);
      });

      testWithFlameGame('NineTileBoxComponent', (game) async {
        final component = NineTileBoxComponent(
          nineTileBox: NineTileBox(Sprite(a), tileSize: 1, destTileSize: 1),
          size: Vector2.all(10),
        );
        await game.ensureAdd(component);
        expect(cache.retainCount('a'), 1);

        component.nineTileBox = NineTileBox(
          Sprite(b),
          tileSize: 1,
          destTileSize: 1,
        );
        expect(cache.retainCount('a'), 0);
        expect(cache.retainCount('b'), 1);

        component.removeFromParent();
        await game.ready();
        expect(cache.retainCount('b'), 0);
      });

      testWithFlameGame('IsometricTileMapComponent', (game) async {
        final component = IsometricTileMapComponent(
          SpriteSheet(image: a, srcSize: Vector2.all(1)),
          [
            [0],
          ],
        );
        await game.ensureAdd(component);
        expect(cache.retainCount('a'), 1);

        component.tileset = SpriteSheet(image: b, srcSize: Vector2.all(1));
        expect(cache.retainCount('a'), 0);
        expect(cache.retainCount('b'), 1);

        component.removeFromParent();
        await game.ready();
        expect(cache.retainCount('b'), 0);
      });

      testWithFlameGame('ParallaxComponent', (game) async {
        final component = ParallaxComponent(
          parallax: Parallax([
            ParallaxLayer(ParallaxImage(a)),
            ParallaxLayer(ParallaxImage(b)),
          ]),
        );
        await game.ensureAdd(component);
        expect(cache.retainCount('a'), 1);
        expect(cache.retainCount('b'), 1);

        component.parallax = Parallax([ParallaxLayer(ParallaxImage(b))]);
        expect(cache.retainCount('a'), 0);
        expect(cache.retainCount('b'), 1);

        component.removeFromParent();
        await game.ready();
        expect(cache.retainCount('b'), 0);
      });
    });
  });
}
