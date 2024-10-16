import 'package:dashbook/dashbook.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

final anchorOptions = Anchor.values.map((e) => e.name).toList();

Widget partialSpriteWidgetBuilder(DashbookContext ctx) {
  return Container(
    width: ctx.numberProperty('container width', 400),
    height: ctx.numberProperty('container height', 200),
    decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
    child: SpriteWidget.asset(
      path: 'bomb_ptero.png',
      srcPosition: Vector2(
        ctx.numberProperty('srcPosition.x', 48),
        ctx.numberProperty('srcPosition.y', 0),
      ),
      srcSize: Vector2(
        ctx.numberProperty('srcSize.x', 48),
        ctx.numberProperty('srcSize.y', 32),
      ),
      anchor: Anchor.valueOf(
        ctx.listProperty('anchor', 'center', anchorOptions),
      ),
    ),
  );
}
