import 'package:dashbook/dashbook.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final anchorOptions = Anchor.values.map((e) => e.name).toList();

Widget spriteWidgetBuilder(DashbookContext ctx) {
  return Container(
    width: ctx.numberProperty('container width', 400),
    height: ctx.numberProperty('container height', 200),
    decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
    child: SpriteWidget.asset(
      path: 'shield.png',
      anchor: Anchor.valueOf(
        ctx.listProperty('anchor', 'center', anchorOptions),
      ),
    ),
  );
}
