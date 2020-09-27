import 'dart:ui';

import '../flare_animation.dart';
import 'component.dart';

@Deprecated("Use flame_flare package instead")
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

  void updateAnimation(String animation) {
    if (loaded()) {
      _flareAnimation.updateAnimation(animation);
    }
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
    super.update(dt);
    if (loaded()) {
      _flareAnimation.update(dt);
    }
  }

  @override
  set width(_width) {
    super.width = _width;
    if (loaded()) {
      _flareAnimation.width = width;
    }
  }

  @override
  set height(_height) {
    super.height = _height;
    if (loaded()) {
      _flareAnimation.height = height;
    }
  }
}
