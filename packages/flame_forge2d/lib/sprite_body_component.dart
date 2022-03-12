import 'package:flame/components.dart';

import 'forge2d_game.dart';
import 'position_body_component.dart';

@Deprecated(
  'Add a SpriteComponent as a child to the BodyComponent instead. '
  'Will be removed in 0.10.0',
)
abstract class SpriteBodyComponent<T extends Forge2DGame>
    extends PositionBodyComponent<T, SpriteComponent> {
  /// Make sure that the [size] of the sprite matches the bounding shape of the
  /// body that is create in createBody()
  SpriteBodyComponent(
    Sprite sprite,
    Vector2 spriteSize, {
    int? priority,
  }) : super(
          positionComponent: SpriteComponent(
            size: spriteSize,
            sprite: sprite,
            priority: priority,
          ),
          size: spriteSize,
        );
}
