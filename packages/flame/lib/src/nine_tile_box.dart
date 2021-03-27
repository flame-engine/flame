import 'dart:ui';

import 'extensions/vector2.dart';
import 'palette.dart';
import 'sprite.dart';

/// This allows you to create a rectangle textured with a 9-sliced image.
///
/// How it works is that you have a template image in a 3x3 grid, made up of 9 tiles,
/// and a new rectangle can be draw by keeping the 4 corners, expanding the 4 sides only
/// in the direction in which they are located and expanding the center in both directions.
/// That allows you to have non distorted borders.
class NineTileBox {
  static final _whitePaint = BasicPalette.white.paint();

  /// The sprite used to render the box, must be a 3x3 grid of square tiles.
  Sprite sprite;

  /// The size of each tile in the source sprite image.
  int tileSize;

  /// The size each tile becomes when rendered (optionally used to scale the src image).
  late int destTileSize;

  /// Creates a nine-box instance.
  ///
  /// [sprite] is the 3x3 grid and [tileSize] is the size of each tile.
  /// The src sprite must a square of size 3*[tileSize].
  ///
  /// If [tileSize] is not provided, the width of the sprite is assumed as the size.
  /// Otherwise the width and height properties of the sprite are ignored.
  ///
  /// If [destTileSize] is not provided, the evaluated [tileSize] is used instead
  /// (so no scaling happens).
  NineTileBox(this.sprite, {int? tileSize, int? destTileSize})
      : tileSize = tileSize ?? sprite.src.width.toInt() {
    this.destTileSize = destTileSize ?? this.tileSize;
  }

  /// Renders this nine box with the dimensions provided by [rect].
  void drawRect(Canvas c, Rect rect) {
    final position = Vector2(rect.left, rect.top);
    final size = Vector2(rect.width, rect.height);
    draw(c, position, size);
  }

  /// Renders this nine box as a rectangle at [position] with size [size].
  void draw(Canvas c, Vector2 position, Vector2 size) {
    // corners
    _drawTile(c, _getDest(position), 0, 0);
    final bottomLeft = position + Vector2(0, size.y - destTileSize);
    _drawTile(c, _getDest(bottomLeft), 0, 2);
    final topRight = position + Vector2(size.x - destTileSize, 0);
    _drawTile(c, _getDest(topRight), 2, 0);
    final bottomRight = Vector2(topRight.x, bottomLeft.y);
    _drawTile(c, _getDest(bottomRight), 2, 2);

    // horizontal sides
    final mx = size.x - 2 * destTileSize;
    final middleLeft = position + Vector2Extension.fromInts(destTileSize, 0);
    _drawTile(c, _getDest(middleLeft, width: mx), 1, 0);
    final middleRight = middleLeft + Vector2(0, size.y - destTileSize);
    _drawTile(c, _getDest(middleRight, width: mx), 1, 2);

    // vertical sides
    final my = size.y - 2 * destTileSize;
    final topCenter = position + Vector2Extension.fromInts(0, destTileSize);
    _drawTile(c, _getDest(topCenter, height: my), 0, 1);
    final bottomCenter = topCenter + Vector2(size.x - destTileSize, 0);
    _drawTile(c, _getDest(bottomCenter, height: my), 2, 1);

    // center
    final center = position + Vector2.all(destTileSize.toDouble());
    _drawTile(c, _getDest(center, width: mx, height: my), 1, 1);
  }

  Rect _getDest(Vector2 position, {double? width, double? height}) {
    final w = width ?? _destTileSizeDouble;
    final h = height ?? _destTileSizeDouble;
    return Rect.fromLTWH(position.x, position.y, w, h);
  }

  double get _tileSizeDouble => tileSize.toDouble();

  double get _destTileSizeDouble => destTileSize.toDouble();

  void _drawTile(Canvas c, Rect dest, int i, int j) {
    final xSrc = sprite.src.left + _tileSizeDouble * i;
    final ySrc = sprite.src.top + _tileSizeDouble * j;
    final src = Rect.fromLTWH(xSrc, ySrc, _tileSizeDouble, _tileSizeDouble);
    c.drawImageRect(sprite.image, src, dest, _whitePaint);
  }
}
