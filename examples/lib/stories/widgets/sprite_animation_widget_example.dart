import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

class SpriteAnimationWidgetExample extends StatelessWidget {
  const SpriteAnimationWidgetExample({
    required this.width,
    required this.height,
    required this.playing,
    required this.anchor,
    required this.paint,
    super.key,
  });

  final double width;
  final double height;
  final bool playing;
  final Anchor anchor;
  final Paint? paint;

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

class SizedSpriteAnimationWidgetExample extends StatelessWidget {
  const SizedSpriteAnimationWidgetExample({
    required this.size,
    required this.playing,
    required this.anchor,
    required this.paint,
    super.key,
  });

  final Size size;
  final bool playing;
  final Anchor anchor;
  final Paint? paint;

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
