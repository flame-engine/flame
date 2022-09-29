import 'package:flame/components.dart';
import 'package:flutter_isolates_example/constants.dart';
import 'package:flutter_isolates_example/standard/int_vector2.dart';

mixin ColonistsObject on PositionComponent {
  IntVector2 get tileSize;

  IntVector2 get tilePosition => IntVector2(
        x ~/ Constants.tileSize,
        y ~/ Constants.tileSize,
      );
}

abstract class StaticColonistsObject extends SpriteComponent
    with ColonistsObject {
  Sprite get objectSprite;

  double get difficulty;

  @override
  IntVector2 get tileSize;

  @override
  IntVector2 get tilePosition => IntVector2(
        x ~/ Constants.tileSize,
        y ~/ Constants.tileSize,
      );

  StaticColonistsObject(int x, int y) {
    sprite = objectSprite;
    width = tileSize.x * Constants.tileSize;
    height = tileSize.y * Constants.tileSize;
    super.y = y * Constants.tileSize;
    super.x = x * Constants.tileSize;
  }
}
