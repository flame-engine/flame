import 'package:flame/extensions/vector2.dart';
import 'package:flutter/material.dart' hide Animation;
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:dashbook/dashbook.dart';

import 'package:flame/widgets/nine_tile_box.dart';
import 'package:flame/widgets/sprite_button.dart';
import 'package:flame/widgets/sprite_widget.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flame/anchor.dart';

Anchor parseAnchor(String name) {
  switch (name) {
    case 'Anchor.topLeft':
      return Anchor.topLeft;
    case 'Anchor.topCenter':
      return Anchor.topCenter;
    case 'Anchor.topRight':
      return Anchor.topRight;
    case 'Anchor.centerLeft':
      return Anchor.centerLeft;
    case 'Anchor.center':
      return Anchor.center;
    case 'Anchor.centerRight':
      return Anchor.centerRight;
    case 'Anchor.bottomLeft':
      return Anchor.bottomLeft;
    case 'Anchor.bottomCenter':
      return Anchor.bottomCenter;
    case 'Anchor.bottomRight':
      return Anchor.bottomRight;
  }

  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dashbook = Dashbook();

  final nineTileBoxImage = await Flame.images.load('nine_tile_box.png');
  dashbook.storiesOf('NineTileBox').decorator(CenterDecorator()).add(
      'default',
      (ctx) => Container(
            width: ctx.numberProperty('width', 200),
            height: ctx.numberProperty('height', 200),
            child: NineTileBox(
              image: nineTileBoxImage,
              tileSize: 16,
              destTileSize: 50,
              child: const Center(
                child: const Text(
                  'Cool label',
                  style: const TextStyle(
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ));

  final buttonsImage = await Flame.images.load('buttons.png');
  final _buttons = SpriteSheet(
    image: buttonsImage,
    srcSize: Vector2(60, 20),
  );
  dashbook.storiesOf('SpriteButton').decorator(CenterDecorator()).add(
        'default',
        (ctx) => Container(
          padding: const EdgeInsets.all(20),
          child: SpriteButton(
            onPressed: () {
              print('Pressed');
            },
            label: const Text(
              'Sprite Button',
              style: const TextStyle(color: const Color(0xFF5D275D)),
            ),
            sprite: _buttons.getSprite(0, 0),
            pressedSprite: _buttons.getSprite(1, 0),
            width: ctx.numberProperty('width', 250),
            height: ctx.numberProperty('height', 75),
          ),
        ),
      );

  final anchorOptions = [
    'Anchor.topLeft',
    'Anchor.topCenter',
    'Anchor.topRight',
    'Anchor.centerLeft',
    'Anchor.center',
    'Anchor.centerRight',
    'Anchor.bottomLeft',
    'Anchor.bottomCenter',
    'Anchor.bottomRight',
  ];
  final shieldImage = await Flame.images.load('shield.png');
  final shieldSprite = Sprite(shieldImage);
  dashbook.storiesOf('SpriteWidget').decorator(CenterDecorator()).add(
        'default',
        (ctx) => Container(
          width: ctx.numberProperty('container width', 400),
          height: ctx.numberProperty('container height', 200),
          child: SpriteWidget(
            sprite: shieldSprite,
            anchor: parseAnchor(
                  ctx.listProperty('anchor', 'Anchor.center', anchorOptions),
                ) ??
                Anchor.topLeft,
          ),
        ),
      );

  final pteroImage = await Flame.images.load('bomb_ptero.png');
  final _animationSpriteSheet = SpriteSheet(
    image: pteroImage,
    srcSize: Vector2(48, 32),
  );
  final _animation = _animationSpriteSheet.createAnimation(
    row: 0,
    stepTime: 0.2,
    to: 3,
    loop: true,
  );
  dashbook.storiesOf('AnimationWidget').decorator(CenterDecorator()).add(
        'default',
        (ctx) => Container(
          width: ctx.numberProperty('container width', 400),
          height: ctx.numberProperty('container height', 200),
          child: SpriteAnimationWidget(
            animation: _animation,
            playing: ctx.boolProperty('playing', true),
            anchor: parseAnchor(
                  ctx.listProperty('anchor', 'Anchor.center', anchorOptions),
                ) ??
                Anchor.topLeft,
          ),
        ),
      );

  runApp(dashbook);
}
