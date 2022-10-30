import 'package:dashbook/dashbook.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

final anchorOptions = Anchor.values.map((e) => e.name).toList();

Widget spriteAnimationWidgetBuilder(DashbookContext ctx) {
  return Container(
    width: ctx.numberProperty('container width', 400),
    height: ctx.numberProperty('container height', 200),
    child: SpriteAnimationWidget.asset(
      path: 'bomb_ptero.png',
      data: SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2(48, 32),
      ),
      playing: ctx.boolProperty('playing', true),
      anchor: Anchor.valueOf(
        ctx.listProperty('anchor', 'center', anchorOptions),
      ),
    ),
  );
}
