import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/spritesheet.dart';
import 'package:dashbook/dashbook.dart';

import 'package:flame/widgets/nine_tile_box.dart';
import 'package:flame/widgets/sprite_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final nineTileBoxImage = await Flame.images.load('nine_tile_box.png');
  await Flame.images.load('buttons.png');

  final _buttons = SpriteSheet(
    imageName: 'buttons.png',
    textureHeight: 20,
    textureWidth: 60,
    columns: 1,
    rows: 2,
  );

  final dashbook = Dashbook();

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

  runApp(dashbook);
}
