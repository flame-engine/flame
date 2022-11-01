import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_isolates_example/constants.dart';
import 'package:flutter_isolates_example/objects/colonists_object.dart';
import 'package:flutter_isolates_example/standard/int_vector2.dart';

class Bread extends StaticColonistsObject {
  @override
  Sprite objectSprite = Sprite(Flame.images.fromCache('bread.png'));

  @override
  IntVector2 tileSize = const IntVector2(1, 1);

  Bread(super.x, super.y);

  @override
  String toString() {
    return 'Bread(${x / Constants.tileSize.toInt()}, '
        '${y / Constants.tileSize.toInt()})';
  }

  @override
  double difficulty = 11.3;
}
