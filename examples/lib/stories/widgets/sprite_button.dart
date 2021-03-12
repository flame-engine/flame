import 'package:dashbook/dashbook.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

Widget spriteButtonBuilder(DashbookContext ctx) {
  final _buttons = SpriteSheet(
    image: Flame.images.fromCache('buttons.png'),
    srcSize: Vector2(60, 20),
  );

  return Container(
    padding: const EdgeInsets.all(20),
    child: SpriteButton(
      onPressed: () {
        print('Pressed');
      },
      label: const Text(
        'Sprite Button',
        style: TextStyle(color: Color(0xFF5D275D)),
      ),
      sprite: _buttons.getSprite(0, 0),
      pressedSprite: _buttons.getSprite(1, 0),
      width: ctx.numberProperty('width', 250),
      height: ctx.numberProperty('height', 75),
    ),
  );
}
