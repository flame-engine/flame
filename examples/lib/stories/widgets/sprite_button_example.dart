import 'package:dashbook/dashbook.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

Widget spriteButtonBuilder(DashbookContext ctx) {
  return Container(
    padding: const EdgeInsets.all(20),
    child: SpriteButton.asset(
      path: 'buttons.png',
      pressedPath: 'buttons.png',
      srcPosition: Vector2(0, 0),
      srcSize: Vector2(60, 20),
      pressedSrcPosition: Vector2(0, 20),
      pressedSrcSize: Vector2(60, 20),
      onPressed: () {
        // Do something
      },
      label: const Text(
        'Sprite Button',
        style: TextStyle(color: Color(0xFF5D275D)),
      ),
      width: ctx.numberProperty('width', 250),
      height: ctx.numberProperty('height', 75),
    ),
  );
}
