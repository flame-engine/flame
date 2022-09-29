import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_isolates_example/objects/colonists_object.dart';
import 'package:flutter_isolates_example/standard/int_vector2.dart';

class Cheese extends StaticColonistsObject {
  @override
  final Sprite objectSprite = Sprite(Flame.images.fromCache('cheese.png'));

  @override
  final IntVector2 tileSize = const IntVector2(1, 1);

  Cheese(super.x, super.y);

  @override
  double difficulty = 8.6;
}
