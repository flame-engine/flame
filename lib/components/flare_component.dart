import 'dart:ui';

import 'component.dart';
import 'package:flame/flare_animation.dart';

class FlareComponent extends PositionComponent {
  FlareAnimation _flareAnimation;

  FlareComponent(
      String fileName, String animation, double width, double height) {
    FlareAnimation.load(fileName).then((loadedFlareAnimation) {
      _flareAnimation = loadedFlareAnimation;

      _flareAnimation.updateAnimation(animation);
      _flareAnimation.width = width;
      _flareAnimation.height = height;
    });
  }

  @override
  bool loaded() => _flareAnimation != null;

  @override
  void render(Canvas canvas) {
    if (_flareAnimation != null) {
      _flareAnimation.render(canvas);
    }
  }

  @override
  void update(double dt) {
    if (_flareAnimation != null) {
      _flareAnimation.x = x;
      _flareAnimation.y = y;

      _flareAnimation.update(dt);
    }
  }
}
