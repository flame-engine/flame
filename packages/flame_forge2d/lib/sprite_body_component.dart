import 'package:flame/components.dart';

import 'position_body_component.dart';

abstract class SpriteBodyComponent extends PositionBodyComponent {
  /// Make sure that the [size] of the sprite matches the bounding shape of the
  /// body that is create in createBody()
  SpriteBodyComponent(
    Sprite sprite,
    Vector2 spriteSize,
  ) : super(SpriteComponent(size: spriteSize, sprite: sprite), spriteSize);
}
