import 'package:dashbook/dashbook.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

final anchorOptions = Anchor.values.map((e) => e.name).toList();

Widget spriteAnimationWidgetBuilder(DashbookContext ctx) {
  final _animationSpriteSheet = SpriteSheet(
    image: Flame.images.fromCache('bomb_ptero.png'),
    srcSize: Vector2(48, 32),
  );
  final _animation = _animationSpriteSheet.createAnimation(
    row: 0,
    stepTime: 0.2,
    to: 3,
  );
  return Container(
    width: ctx.numberProperty('container width', 400),
    height: ctx.numberProperty('container height', 200),
    child: SpriteAnimationWidget(
      animation: _animation,
      playing: ctx.boolProperty('playing', true),
      anchor: Anchor.valueOf(
        ctx.listProperty('anchor', 'center', anchorOptions),
      ),
    ),
  );
}
