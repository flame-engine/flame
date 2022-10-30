import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/spritesheet.dart';
import 'package:meta/meta.dart';

/// This is just a pair of <int, int>.
///
/// Represents a position in a matrix, or in this case, on the tilemap.
@immutable
class Block {
  /// x and y coordinates on the matrix
  final int x, y;

  const Block(this.x, this.y);

  @override
  String toString() => '($x, $y)';

  Vector2 toVector2() => Vector2Extension.fromInts(x, y);

  @override
  bool operator ==(Object other) {
    if (other is! Block) {
      return false;
    }
    return other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
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
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : _renderSprite = Sprite(tileset.image);

  /// This is the size the tiles will be drawn (either original or overwritten).
  Vector2 get effectiveTileSize => destTileSize ?? tileset.srcSize;

  /// The current scaling factor for the isometric view.
  double get scalingFactor => effectiveTileSize.y / effectiveTileSize.x;

  /// This is the vertical height of each block; by default it's half the
  /// tile size.
  double get effectiveTileHeight => tileHeight ?? (effectiveTileSize.y / 2);

  Sprite _renderSprite;
  @override
  void render(Canvas c) {
    _renderSprite.image = tileset.image;
    final size = effectiveTileSize;
    for (var i = 0; i < matrix.length; i++) {
      for (var j = 0; j < matrix[i].length; j++) {
        final element = matrix[i][j];
        if (element != -1) {
          _renderSprite = tileset.getSpriteById(element);
          final p = getBlockRenderPositionInts(j, i);
          _renderSprite.render(
            c,
            position: p,
            size: size,
          );
        }
      }
    }
  }

  /// Get the position in which a block is rendered in, in the isometric space.
  ///
  /// This does not include the (x,y) PositionComponent offset!
  /// This assumes the tile sprite as a rectangular tile.
  /// This is the opposite of [getBlockRenderedAt].
  Vector2 getBlockRenderPosition(Block block) {
    return getBlockRenderPositionInts(block.x, block.y);
  }

  /// Same as getBlockRenderPosition but the arguments are exploded as integers.
  Vector2 getBlockRenderPositionInts(int i, int j) {
    final halfTile = Vector2(
      effectiveTileSize.x / 2,
      (effectiveTileSize.y / 2) / scalingFactor,
    )..multiply(scale);
    final pos = Vector2(i.toDouble(), j.toDouble())..multiply(halfTile);
    return cartToIso(pos) - halfTile;
  }

  /// Get the position of the center of the surface of the isometric tile in
  /// the cartesian coordinate space.
  ///
  /// This is the opposite of [getBlock].
  Vector2 getBlockCenterPosition(Block block) {
    final tile = effectiveTileSize;
    final result = getBlockRenderPosition(block) +
        (Vector2(tile.x / 2, tile.y - effectiveTileHeight - tile.y / 4)
          ..multiply(scale));
    return result;
  }

  /// Converts a coordinate from the isometric space to the cartesian space.
  Vector2 isoToCart(Vector2 p) {
    final x = p.y / scalingFactor + p.x / 2;
    final y = p.y - p.x * scalingFactor / 2;
    return Vector2(x, y);
  }

  /// Converts a coordinate from the cartesian space to the isometric space.
  Vector2 cartToIso(Vector2 p) {
    final x = p.x - p.y;
    final y = ((p.x + p.y) * scalingFactor) / 2;
    return Vector2(x, y);
  }

  /// Get which block's surface is at isometric position [p].
  ///
  /// This can be used to handle clicks or hovers.
  /// This is the opposite of [getBlockCenterPosition].
  Block getBlock(Vector2 p) {
    final halfTile = (effectiveTileSize / 2)..multiply(scale);
    final multiplier = 1 - halfTile.y / (2 * effectiveTileHeight * scale.x);
    final delta = halfTile.clone()..multiply(Vector2(1, multiplier));
    final cart = isoToCart(p - position + delta);
    final px = (cart.x / halfTile.x - 1).ceil();
    final py = (cart.y / halfTile.y).ceil();
    return Block(px, py);
  }

  /// Get which block should be rendered on position [p].
  ///
  /// This is the opposite of [getBlockRenderPosition].
  Block getBlockRenderedAt(Vector2 p) {
    final tile = effectiveTileSize;
    return getBlock(
      p +
          (Vector2(tile.x / 2, tile.y - effectiveTileHeight - tile.y / 4)
            ..multiply(scale)),
    );
  }

  /// Sets the block value into the matrix.
  void setBlockValue(Block pos, int block) {
    matrix[pos.y][pos.x] = block;
  }

  /// Gets the block value from the matrix.
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
