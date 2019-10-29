import 'dart:ui';

import 'component.dart';
import 'package:flame/flare_animation.dart';

class FlareComponent extends PositionComponent {
  FlareAnimation _flareAnimation;

  FlareComponent(
      String fileName, String animation, double width, double height) {
    this.width = width;
    this.height = height;

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
    prepareCanvas(canvas);
    _flareAnimation.render(canvas, x: 0, y: 0);
  }

  @override
  void update(double dt) {
    if (_flareAnimation != null) {
      _flareAnimation.update(dt);
    }
  }
}
