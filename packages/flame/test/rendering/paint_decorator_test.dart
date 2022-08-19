import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_resources/load_image.dart';

void main() {
  group('PaintDecorator', () {
    testGolden(
      'blur effect',
      (game) async {
        final image = await loadImage('flame.png');
        game.addAll([
          SpriteComponent(sprite: Sprite(image)),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.blur(0, 10),
            position: Vector2(150, 0),
          ),
        ]);
      },
      size: Vector2(300, 220),
      goldenFile: '../_goldens/paint_decorator_blur.png',
    );

    testGolden(
      'grayscale effect',
      (game) async {
        final image = await loadImage('flame.png');
        game.addAll([
          SpriteComponent(sprite: Sprite(image)),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.grayscale(),
            position: Vector2(150, 0),
          ),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.grayscale(opacity: 0.5),
            position: Vector2(300, 0),
          ),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.grayscale(opacity: 0.25),
            position: Vector2(450, 0),
          ),
        ]);
      },
      size: Vector2(600, 220),
      goldenFile: '../_goldens/paint_decorator_grayscale.png',
    );

    testGolden(
      'tint effect',
      (game) async {
        final image = await loadImage('zz_guitarre.png');
        game.addAll([
          SpriteComponent(sprite: Sprite(image)),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.tint(const Color(0x8800FF00)),
            position: Vector2(100, 0),
          ),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.tint(const Color(0x880000FF)),
            position: Vector2(200, 0),
          ),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.tint(const Color(0xAAFFFFFF)),
            position: Vector2(300, 0),
          ),
        ]);
      },
      size: Vector2(400, 300),
      goldenFile: '../_goldens/paint_decorator_tinted.png',
    );

    testGolden(
      'grayscale/tinted with blur',
      (game) async {
        final image = await loadImage('zz_guitarre.png');
        const color = Color(0x88EBFF7F);
        game.addAll([
          SpriteComponent(sprite: Sprite(image)),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.grayscale()..addBlur(3),
            position: Vector2(100, 0),
          ),
          _DecoratedSprite(
            sprite: Sprite(image),
            decorator: PaintDecorator.tint(color)..addBlur(3),
            position: Vector2(200, 0),
          ),
        ]);
      },
      size: Vector2(300, 300),
      goldenFile: '../_goldens/paint_decorator_with_blur.png',
    );
  });
}

class _DecoratedSprite extends SpriteComponent {
  _DecoratedSprite({
    super.sprite,
    super.position,
    required Decorator decorator,
  }) {
    this.decorator.addLast(decorator);
  }
}
