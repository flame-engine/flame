import 'package:dashbook/dashbook.dart';
import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

final anchorOptions = Anchor.values.map((e) => e.name).toList();

Widget spriteWidgetBuilder(DashbookContext ctx) {
  return Container(
    width: ctx.numberProperty('container width', 400),
    height: ctx.numberProperty('container height', 200),
    child: SpriteWidget(
      sprite: Sprite(Flame.images.fromCache('shield.png')),
      anchor: Anchor.valueOf(
        ctx.listProperty('anchor', 'center', anchorOptions),
      ),
    ),
  );
}
