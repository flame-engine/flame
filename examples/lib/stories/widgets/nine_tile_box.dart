import 'package:dashbook/dashbook.dart';
import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

Widget nineTileBoxBuilder(DashbookContext ctx) {
  return Container(
    width: ctx.numberProperty('width', 200),
    height: ctx.numberProperty('height', 200),
    child: NineTileBox(
      image: Flame.images.fromCache('nine-box.png'),
      tileSize: 8,
      destTileSize: 50,
      child: const Center(
        child: Text(
          'Cool label',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    ),
  );
}
