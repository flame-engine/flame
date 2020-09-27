import 'dart:ui';

import 'package:flame/components/component.dart';

import '../flame.dart';
import '../position.dart';
import '../sprite.dart';

/// This represents an isometric tileset to be used in a tilemap.
///
/// It's basically a grid of squares, each square has a tile, in order.
/// The block ids are calculated going row per row, left to right, top to
/// bottom.
///
/// This class will cache the usage of sprites to improve performance.
class IsometricTileset {
  /// The image for this tileset.
  final Image tileset;

  /// The size of each square block within the image.
  ///
  /// The image width and height must be multiples of this number.
  final int size;

  final Map<int, Sprite> _spriteCache = {};

  IsometricTileset(this.tileset, this.size);

  /// Compute the number of columns the image has
  /// by using the image width and tile size.
  int get columns => tileset.width ~/ size;

  /// Compute the number of rows the image has
  /// by using the image height and tile size.
  int get rows => tileset.height ~/ size;

  /// Get a sprite to render one specific tile given its id.
  ///
  /// The ids are assigned left to right, top to bottom, row per row.
  /// The returned sprite will be cached, so don't modify it!
  Sprite getTile(int tileId) {
    return _spriteCache[tileId] ??= _computeTile(tileId);
  }

  Sprite _computeTile(int tileId) {
    final i = tileId % columns;
    final j = tileId ~/ columns;
    final s = size.toDouble();
    return Sprite.fromImage(tileset, x: s * i, y: s * j, width: s, height: s);
  }

  /// Load a tileset based on a file name.
  static Future<IsometricTileset> load(String fileName, int size) async {
    final image = await Flame.images.load(fileName);
    return IsometricTileset(image, size);
  }
}

/// This is just a pair of int, int.
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
/// tileset, in witch the integers are the block ids.
///
/// It can change the scale of each block by using the optional destTileSize
/// property.
class IsometricTileMapComponent extends PositionComponent {
  /// This is the tileset that will be used to render this map.
  IsometricTileset tileset;

  /// The positions of each block will be placed respecting this matrix.
  List<List<int>> matrix;

  /// Optionally provide a new tile size to render it scaled.
  int destTileSize;

  IsometricTileMapComponent(this.tileset, this.matrix, {this.destTileSize});

  /// This is the size the tiles will be drawn (either original or overwritten).
  int get effectiveTileSize => destTileSize ?? tileset.size;

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    final size = Position.fromInts(effectiveTileSize, effectiveTileSize);
    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        final element = matrix[i][j];
        if (element != -1) {
          final sprite = tileset.getTile(element);
          final p = getBlockPositionInts(j, i);
          sprite.renderRect(c, Position.rectFrom(p, size));
        }
      }
    }
  }

  /// Get the position in witch a block must be in the isometric space.
  ///
  /// This does not include the (x,y) PositionComponent offset!
  Position getBlockPosition(Block block) {
    return getBlockPositionInts(block.x, block.y);
  }

  Position getBlockPositionInts(int i, int j) {
    final s = effectiveTileSize.toDouble() / 2;
    return cartToIso(Position(i * s, j * s)).minus(Position(s, 0));
  }

  /// Converts a coordinate from the isometric space to the cartesian space.
  Position isoToCart(Position p) {
    final x = (2 * p.y + p.x) / 2;
    final y = (2 * p.y - p.x) / 2;
    return Position(x, y);
  }

  /// Converts a coordinate from the cartesian space to the isometric space.
  Position cartToIso(Position p) {
    final x = p.x - p.y;
    final y = (p.x + p.y) / 2;
    return Position(x, y);
  }

  /// Get what block is at isometric position p.
  ///
  /// This can be used to handle clicks or hovers.
  Block getBlock(Position p) {
    final s = effectiveTileSize.toDouble() / 2;
    final cart = isoToCart(p.clone().minus(toPosition()));
    final px = cart.x ~/ s;
    final py = cart.y ~/ s;
    return Block(px, py);
  }

  /// Return whether the matrix contains a block in its bounds.
  bool containsBlock(Block block) {
    return block.x >= 0 &&
        block.x < matrix.length &&
        block.y >= 0 &&
        block.y < matrix[block.x].length;
  }
}
