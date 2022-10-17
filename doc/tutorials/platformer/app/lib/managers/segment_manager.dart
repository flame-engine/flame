import 'package:EmberQuest/objects/ground_block.dart';
import 'package:EmberQuest/objects/platform_block.dart';
import 'package:EmberQuest/objects/star.dart';
import 'package:flame/components.dart';

class Block {
  //gridPosition position is always segment based X,Y.
  //0,0 is the bottom left corner
  //10,10 is the upper right corne
  final Vector2 gridPosition;
  final Type blockType;
  Block(this.gridPosition, this.blockType);
}

final segments = [
  segment0,
  segment1,
  segment2,
  segment3,
  segment4,
];

final segment0 = [
  Block(Vector2(0, 0), GroundBlock),
  Block(Vector2(1, 0), GroundBlock),
  Block(Vector2(2, 0), GroundBlock),
  Block(Vector2(3, 0), GroundBlock),
  Block(Vector2(4, 0), GroundBlock),
  Block(Vector2(5, 0), GroundBlock),
  Block(Vector2(5, 3), PlatformBlock),
  Block(Vector2(6, 0), GroundBlock),
  Block(Vector2(6, 3), PlatformBlock),
  Block(Vector2(7, 0), GroundBlock),
  Block(Vector2(7, 3), PlatformBlock),
  Block(Vector2(8, 0), GroundBlock),
  Block(Vector2(8, 3), PlatformBlock),
  Block(Vector2(9, 0), GroundBlock),
];

final segment1 = [
  Block(Vector2(0, 0), GroundBlock),
  Block(Vector2(1, 0), GroundBlock),
  Block(Vector2(1, 1), PlatformBlock),
  Block(Vector2(1, 2), PlatformBlock),
  Block(Vector2(1, 3), PlatformBlock),
  Block(Vector2(2, 6), PlatformBlock),
  Block(Vector2(2, 7), Star),
  Block(Vector2(3, 6), PlatformBlock),
  Block(Vector2(6, 5), PlatformBlock),
  Block(Vector2(7, 5), PlatformBlock),
  Block(Vector2(8, 0), GroundBlock),
  Block(Vector2(8, 1), PlatformBlock),
  Block(Vector2(8, 5), PlatformBlock),
  Block(Vector2(9, 0), GroundBlock),
];

final segment2 = [
  Block(Vector2(0, 0), GroundBlock),
  Block(Vector2(1, 0), GroundBlock),
  Block(Vector2(2, 0), GroundBlock),
  Block(Vector2(3, 0), GroundBlock),
  Block(Vector2(3, 3), PlatformBlock),
  Block(Vector2(4, 0), GroundBlock),
  Block(Vector2(4, 3), PlatformBlock),
  Block(Vector2(5, 0), GroundBlock),
  Block(Vector2(5, 3), PlatformBlock),
  Block(Vector2(6, 0), GroundBlock),
  Block(Vector2(6, 3), PlatformBlock),
  Block(Vector2(6, 4), PlatformBlock),
  Block(Vector2(6, 5), PlatformBlock),
  Block(Vector2(7, 0), GroundBlock),
  Block(Vector2(8, 0), GroundBlock),
  Block(Vector2(9, 0), GroundBlock),
];

final segment3 = [
  Block(Vector2(0, 0), GroundBlock),
  Block(Vector2(1, 0), GroundBlock),
  Block(Vector2(2, 0), GroundBlock),
  Block(Vector2(2, 1), PlatformBlock),
  Block(Vector2(2, 2), PlatformBlock),
  Block(Vector2(4, 4), PlatformBlock),
  Block(Vector2(6, 6), PlatformBlock),
  Block(Vector2(7, 0), GroundBlock),
  Block(Vector2(7, 1), PlatformBlock),
  Block(Vector2(8, 0), GroundBlock),
  Block(Vector2(9, 0), GroundBlock),
];

final segment4 = [
  Block(Vector2(0, 0), GroundBlock),
  Block(Vector2(1, 0), GroundBlock),
  Block(Vector2(2, 0), GroundBlock),
  Block(Vector2(2, 3), PlatformBlock),
  Block(Vector2(3, 0), GroundBlock),
  Block(Vector2(3, 3), PlatformBlock),
  Block(Vector2(4, 0), GroundBlock),
  Block(Vector2(5, 0), GroundBlock),
  Block(Vector2(5, 5), PlatformBlock),
  Block(Vector2(6, 0), GroundBlock),
  Block(Vector2(6, 5), PlatformBlock),
  Block(Vector2(7, 0), GroundBlock),
  Block(Vector2(8, 0), GroundBlock),
  Block(Vector2(8, 3), PlatformBlock),
  Block(Vector2(9, 0), GroundBlock),
  Block(Vector2(9, 3), PlatformBlock),
];
