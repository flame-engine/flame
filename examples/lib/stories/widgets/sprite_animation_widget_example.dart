import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

class const SpriteAnimationWidgetExample({
  required final double width,
  required final double height,
  required final bool playing,
  required final Anchor anchor,
  required final Paint? paint,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SpriteAnimationWidget.asset(
        path: 'assets/images/bomb_ptero.png',
        data: SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2(48, 32),
        ),
        playing: playing,
        anchor: anchor,
        paint: paint,
      ),
    );
  }
}

class const SizedSpriteAnimationWidgetExample({
  required final Size size,
  required final bool playing,
  required final Anchor anchor,
  required final Paint? paint,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpriteAnimationWidget.asset(
      size: size,
      path: 'assets/images/bomb_ptero.png',
      data: SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2(48, 32),
      ),
      playing: playing,
      anchor: anchor,
      paint: paint,
    );
  }
}
