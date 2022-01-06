import 'package:flame/components.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_forge2d/position_body_component.dart';

abstract class SpriteAnimationBodyComponent<T extends Forge2DGame>
    extends PositionBodyComponent<T> {
  /// Make sure that the [size] of the sprite matches the bounding shape of the
  /// body that is create in createBody()
  /// 
  /// The [SpriteAnimationComponent] lets you update the animation at runtime.
  SpriteAnimationBodyComponent(
    SpriteAnimationComponent spriteAnimationComponent,
    Vector2 spriteSize,
  ) : super(
          positionComponent: spriteAnimationComponent,
          size: spriteSize,
        );
}
