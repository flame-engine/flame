import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

class RemoveEffectGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    final flower = Flower(
      position: size / 2,
      size: 45,
      onTap: (flower) {
        flower.add(
          RemoveEffect(delay: 3),
        );
      },
    )..anchor = Anchor.center;

    add(
      SpawnBox(
        onTap: () {
          if (!children.contains(flower)) {
            add(
              flower
                ..opacity = 0
                ..add(
                  OpacityEffect.by(
                    1,
                    EffectController(duration: 0.75),
                  ),
                ),
            );
          }
        },
      )
        ..anchor = Anchor.topLeft
        ..size = size,
    );

    add(flower);
  }
}

class SpawnBox extends PositionComponent with TapCallbacks {
  SpawnBox({
    required VoidCallback onTap,
  }) : _onTap = onTap;

  final VoidCallback _onTap;

  @override
  void onTapUp([TapUpEvent? event]) => _onTap.call();

  @override
  void render(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTRB(5, 5, 5, 5), Paint());
  }
}
