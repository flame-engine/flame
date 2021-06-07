import 'dart:ui';

import '../extensions/vector2.dart';
import '../spritesheet.dart';
import 'position_component.dart';

/// This is just a pair of <int, int>.
///
/// Represents a position in a matrix, or in this case, on the tilemap.
class Block {
  /// x and y coordinates on the matrix
  int x, y;

  Block(this.x, this.y);

  @override
  String toString() => '($x, $y)';
}

/// This component renders a tilemap, represented by an int matrix, given a
/// tileset, in which the integers are the block ids.
///
/// It can change the scale of each block by using the optional destTileSize
/// property.
class IsometricTileMapComponent extends PositionComponent {
  /// This is the tileset that will be used to render this map.
  SpriteSheet tileset;

  /// The positions of each block will be placed respecting this matrix.
  List<List<int>> matrix;

  /// Optionally provide a new tile size to render it scaled.
  Vector2? destTileSize;

  /// This is the vertical height of each block in the tile set.
  ///
  /// Note: this must be measured in the destination space.
  double? tileHeight;

  IsometricTileMapComponent(
    this.tileset,
    this.matrix, {
    this.destTileSize,
    this.tileHeight,
    Vector2? position,
    int? priority,
  }) : super(position: position, priority: priority);

  /// This is the size the tiles will be drawn (either original or overwritten).
  Vector2 get effectiveTileSize => destTileSize ?? tileset.srcSize;

  /// This is the vertical height of each block; by default it's half the tile size.
  double get effectiveTileHeight => tileHeight ?? (effectiveTileSize.x / 2);

  @override
  void render(Canvas c) {
    super.render(c);

    final size = effectiveTileSize;
    for (var i = 0; i < matrix.length; i++) {
      for (var j = 0; j < matrix[i].length; j++) {
        final element = matrix[i][j];
        if (element != -1) {
          final sprite = tileset.getSpriteById(element);
          final p = getBlockPositionInts(j, i);
          sprite.render(c, position: p, size: size);
        }
      }
    }
  }

  /// Get the position in which a block must be in the isometric space.
  ///
  /// This does not include the (x,y) PositionComponent offset!
  Vector2 getBlockPosition(Block block) {
    return getBlockPositionInts(block.x, block.y);
  }

  Vector2 getBlockPositionInts(int i, int j) {
    final halfTile = effectiveTileSize / 2;
    final pos = Vector2(i.toDouble(), j.toDouble())..multiply(halfTile);
    return cartToIso(pos) - halfTile;
  }

  /// Converts a coordinate from the isometric space to the cartesian space.
  Vector2 isoToCart(Vector2 p) {
    final x = (2 * p.y + p.x) / 2;
    final y = (2 * p.y - p.x) / 2;
    return Vector2(x, y);
  }

  /// Converts a coordinate from the cartesian space to the isometric space.
  Vector2 cartToIso(Vector2 p) {
    final x = p.x - p.y;
    final y = (p.x + p.y) / 2;
    return Vector2(x, y);
  }

  /// Get what block is at isometric position p.
  ///
  /// This can be used to handle clicks or hovers.
  Block getBlock(Vector2 p) {
    final halfTile = effectiveTileSize / 2;
    final multiplier = 1 - halfTile.y / (2 * effectiveTileHeight);
    final delta = halfTile.clone()..multiply(Vector2(1, multiplier));
    final cart = isoToCart(p - position + delta);
    final px = (cart.x / halfTile.x - 1).ceil();
    final py = (cart.y / halfTile.y).ceil();
    return Block(px, py);
  }

  void setBlockValue(Block pos, int block) {
    matrix[pos.y][pos.x] = block;
  }

  int blockValue(Block pos) {
    return matrix[pos.y][pos.x];
  }

  /// Return whether the matrix contains a block in its bounds.
  bool containsBlock(Block block) {
    return block.y >= 0 &&
        block.y < matrix.length &&
        block.x >= 0 &&
        block.x < matrix[block.y].length;
  }
}
