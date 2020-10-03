import 'dart:ui';

import 'package:flame/extensions/vector2.dart';
import 'package:flutter/foundation.dart';

import '../flare_animation.dart';
import 'position_component.dart';

@Deprecated("Use flame_flare package instead")
class FlareComponent extends PositionComponent {
  FlareAnimation _flareAnimation;

  FlareComponent(
    String fileName,
    String animation,
    Vector2 size,
  ) {
    super.size = size;

    FlareAnimation.load(fileName).then((loadedFlareAnimation) {
      _flareAnimation = loadedFlareAnimation;
      _flareAnimation.updateAnimation(animation);
      _flareAnimation.size = size;
    });
  }

  void updateAnimation(String animation) {
    if (loaded()) {
      _flareAnimation.updateAnimation(animation);
    }
  }

  @override
  set size(Vector2 newSize) {
    super.size = newSize;
    if (loaded()) {
      _flareAnimation.size = size;
    }
  }

  @override
  bool loaded() => _flareAnimation != null;

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _flareAnimation.render(canvas, x: 0, y: 0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (loaded()) {
      _flareAnimation.update(dt);
    }
  }
}
