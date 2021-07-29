import 'package:flame/components.dart';

import 'forge2d_game.dart';
import 'position_body_component.dart';

abstract class SpriteBodyComponent<T extends Forge2DGame>
    extends PositionBodyComponent<T> {
  /// Make sure that the [size] of the sprite matches the bounding shape of the
  /// body that is create in createBody()
  SpriteBodyComponent(
    Sprite sprite,
    Vector2 spriteSize,
  ) : super(SpriteComponent(size: spriteSize, sprite: sprite), spriteSize);
}
