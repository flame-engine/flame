import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/sprite_sheet.dart';
import 'package:meta/meta.dart';

/// This is just a pair of [int, int].
///
/// Represents a position in a matrix, or in this case, on the tilemap.
@immutable
class Block {
  /// x coordinate in the matrix.
  final int x;

  /// y coordinate in the matrix.
  final int y;

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

  /// Where the tileset's image is stored.
  Sprite _renderSprite;

  /// Displacement applied so that the origin of the component
  /// matches the origin of the AABB.
  final Vector2 _offset = Vector2.zero();

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
    super.key,
  }) : _renderSprite = Sprite(tileset.image) {
    _recomputeSizeAndOffset();
  }

  /// This is the size the tiles will be drawn (either original or overwritten).
  Vector2 get effectiveTileSize => destTileSize ?? tileset.srcSize;

  /// The current scaling factor for the isometric view.
  double get scalingFactor => effectiveTileSize.y / effectiveTileSize.x;

  /// This is the vertical height of each block; by default it's half the
  /// tile size.
  double get effectiveTileHeight => tileHeight ?? (effectiveTileSize.y / 2);

  @override
  void render(Canvas canvas) {
    final size = effectiveTileSize;
    for (var i = 0; i < matrix.length; i++) {
      for (var j = 0; j < matrix[i].length; j++) {
        final element = matrix[i][j];
        if (element != -1) {
          _renderSprite = tileset.getSpriteById(element);
          final blockPosition = getBlockRenderPositionInts(j, i);
          _renderSprite.render(
            canvas,
            position: blockPosition,
            size: size,
          );
        }
      }
    }
  }

  @override
  void update(double dt) {
    _recomputeSizeAndOffset();
  }

  /// Get the position in which a block is rendered in, in the isometric space.
  ///
  /// This does not include the (x,y) PositionComponent offset!
  /// This assumes the tile sprite as a rectangular tile.
  /// This is the opposite of [getBlockRenderedAt].
  Vector2 getBlockRenderPosition(Block block) {
    return getBlockRenderPositionInts(block.x, block.y);
  }

  final Vector2 _blockRenderPositionCache = Vector2.zero();
  final Vector2 _cartesianPositionCache = Vector2.zero();

  /// Same as getBlockRenderPosition but the arguments are exploded as integers.
  Vector2 getBlockRenderPositionInts(int i, int j) {
    final halfTile = _blockRenderPositionCache
      ..setValues(
        effectiveTileSize.x / 2,
        (effectiveTileSize.y / 2) / scalingFactor,
      )
      ..multiply(scale);
    final cartesianPosition = _cartesianPositionCache
      ..setValues(i.toDouble(), j.toDouble())
      ..multiply(halfTile);
    return cartToIso(cartesianPosition)
      ..add(_offset)
      ..sub(halfTile);
  }

  /// Get the position of the center of the surface of the isometric tile in
  /// the cartesian coordinate space.
  ///
  /// This is the opposite of [getBlock].
  Vector2 getBlockCenterPosition(Block block) {
    final tile = effectiveTileSize;
    return getBlockRenderPosition(block)..translate(
      (tile.x / 2) * scale.x,
      (tile.y - effectiveTileHeight - tile.y / 4) * scale.y,
    );
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

  final Vector2 _getBlockCache = Vector2.zero();
  final Vector2 _getBlockIsoCache = Vector2.zero();

  /// Get which block's surface is at isometric position [p].
  ///
  /// This can be used to handle clicks or hovers.
  /// This is the opposite of [getBlockCenterPosition].
  Block getBlock(Vector2 p) {
    final halfTile = _getBlockCache
      ..setFrom(effectiveTileSize)
      ..multiply(scale / 2);
    final multiplier = 1 - halfTile.y / (2 * effectiveTileHeight * scale.x);
    final iso = _getBlockIsoCache
      ..setFrom(p)
      ..sub(_offset)
      ..sub(position)
      ..translate(halfTile.x, halfTile.y * multiplier);
    final cart = isoToCart(iso);
    final px = (cart.x / halfTile.x - 1).ceil();
    final py = (cart.y / halfTile.y).ceil();
    return Block(px, py);
  }

  final Vector2 _blockPositionCache = Vector2.zero();

  /// Get which block should be rendered on position [p].
  ///
  /// This is the opposite of [getBlockRenderPosition].
  Block getBlockRenderedAt(Vector2 p) {
    final tile = effectiveTileSize;
    return getBlock(
      _blockPositionCache
        ..setFrom(p)
        ..translate(
          (tile.x / 2) * scale.x,
          (tile.y - effectiveTileHeight - tile.y / 4) * scale.y,
        ),
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

  void _recomputeSizeAndOffset() {
    final width = matrix.fold<int>(
      0,
      (previousValue, element) => max(previousValue, element.length),
    );
    final height = matrix.length;

    size.x = effectiveTileSize.x * width;
    size.y = effectiveTileSize.y * height / 2 + effectiveTileHeight;

    _offset.x = size.x / 2;
    _offset.y = effectiveTileHeight;
  }
}
