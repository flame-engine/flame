import 'dart:ui';

import '../anchor.dart';
import '../components/component.dart';
import '../sprite.dart';
import 'body_component.dart';
import 'box2d_game.dart';

abstract class SpriteBodyComponent extends BodyComponent {
  SpriteComponent spriteComponent;
  final double width;
  final double height;

  /// Make sure that your [width] and [height] of the sprite
  /// matches the bounding rectangle of the body created by createBody()
  SpriteBodyComponent(
    Sprite sprite,
    this.width,
    this.height,
    Box2DGame game,
  ) : super(game) {
    spriteComponent = SpriteComponent.fromSprite(width, height, sprite)
      ..anchor = Anchor.center;
  }

  @override
  bool loaded() => body.isActive() && spriteComponent.loaded();

  @override
  void render(Canvas c) {
    super.render(c);
    if (spriteComponent.loaded()) {
      final screenPosition = viewport.getWorldToScreen(body.position);
      spriteComponent
        ..angle = -body.getAngle()
        ..width = width * viewport.scale
        ..height = height * viewport.scale
        ..x = screenPosition.x
        ..y = screenPosition.y;

      spriteComponent.render(c);
    }
  }
}
