import 'dart:async';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/game.dart';

class HasVisibilityExample extends FlameGame {
  static const String description = '''
    In this example we use the `HasVisibility` mixin to toggle the
    visibility of a component without removing it from the parent
    component.
    This is a non-interactive example.
  ''';

  @override
  Future<void> onLoad() async {
    final flameLogoSprite = await loadSprite('flame.png');

    final flameLogoComponent = LogoComponent(flameLogoSprite);
    add(flameLogoComponent);

    const oneSecDuration = Duration(seconds: 1);
    Timer.periodic(
        oneSecDuration,
        (Timer t) =>
            flameLogoComponent.isVisible = !flameLogoComponent.isVisible);
  }
}

class LogoComponent extends SpriteComponent with HasVisibility {
  LogoComponent(Sprite sprite) : super(sprite: sprite, size: sprite.srcSize);
}
