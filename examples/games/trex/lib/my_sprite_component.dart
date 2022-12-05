import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SpriteComponentDarkOnSecondary extends SpriteComponent {
  SpriteComponentDarkOnSecondary({
    super.sprite,
    super.paint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
  });

  @override
  void render(Canvas canvas) {
    if (canvas is CanvasSecondary) {
      canvas.saveLayer(
        null,
        Paint()
          ..colorFilter = const ColorFilter.mode(
            Color(0xFF000000),
            BlendMode.srcATop,
          ),
      );
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}

class SpriteAnimationGroupComponentDarkOnSecondary<T>
    extends SpriteAnimationGroupComponent<T> {
  SpriteAnimationGroupComponentDarkOnSecondary({
    super.animations,
    super.current,
    super.removeOnFinish,
    super.paint,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
  });

  @override
  void render(Canvas canvas) {
    if (canvas is CanvasSecondary) {
      canvas.saveLayer(
        null,
        Paint()
          ..colorFilter = const ColorFilter.mode(
            Color(0xFF000000),
            BlendMode.srcATop,
          ),
      );
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}
