import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_isolate_example/constants.dart';
import 'package:flame_isolate_example/objects/colonists_object.dart';
import 'package:flame_isolate_example/standard/int_vector2.dart';

class Bread(super.x, super.y) extends StaticColonistsObject {
  @override
  Sprite objectSprite = Sprite(
    Flame.images.fromCache('assets/images/bread.png'),
  );

  @override
  IntVector2 tileSize = const IntVector2(1, 1);

  @override
  String toString() {
    return 'Bread(${x / Constants.tileSize.toInt()}, '
        '${y / Constants.tileSize.toInt()})';
  }

  @override
  double difficulty = 11.3;
}
