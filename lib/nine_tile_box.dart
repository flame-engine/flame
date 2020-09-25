import 'dart:ui';

import 'palette.dart';
import 'sprite.dart';

/// This allows you to create a rectangle textured with a 9-sliced image.
///
/// How it works is that you have a template image in a 3x3 grid, made up of 9 tiles,
/// and a new rectangle can be draw by keeping the 4 corners, expanding the 4 sides only
/// in the direction in which they are located and expanding the center in both directions.
/// That allows you to have non distorted borders.
class NineTileBox {
  /// The sprite used to render the box, must be a 3x3 grid of square tiles.
  Sprite sprite;

  /// The size of each tile in the source sprite image.
  int tileSize;

  /// The size each tile becomes when rendered (optionally used to scale the src image).
  int destTileSize;

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
  NineTileBox(this.sprite, {int tileSize, int destTileSize}) {
    this.tileSize = tileSize ?? sprite.src.width.toInt();
    this.destTileSize = destTileSize ?? tileSize;
  }

  /// Renders this nine box with the dimensions provided by [rect].
  void drawRect(Canvas c, Rect rect) {
    draw(c, rect.left, rect.top, rect.width, rect.height);
  }

  /// Renders this nine box as a rectangle of coordinates ([x], [y]) and size ([width], [height]).
  void draw(Canvas c, double x, double y, double width, double height) {
    if (!sprite.loaded()) {
      return;
    }

    // corners
    _drawTile(c, _getDest(x, y), 0, 0);
    _drawTile(c, _getDest(x, y + height - destTileSize), 0, 2);
    _drawTile(c, _getDest(x + width - destTileSize, y), 2, 0);
    _drawTile(
        c, _getDest(x + width - destTileSize, y + height - destTileSize), 2, 2);

    // horizontal sides
    final mx = width - 2 * destTileSize;
    _drawTile(c, _getDest(x + destTileSize, y, width: mx), 1, 0);
    _drawTile(c,
        _getDest(x + destTileSize, y + height - destTileSize, width: mx), 1, 2);

    // vertical sides
    final my = height - 2 * destTileSize;
    _drawTile(c, _getDest(x, y + destTileSize, height: my), 0, 1);
    _drawTile(c,
        _getDest(x + width - destTileSize, y + destTileSize, height: my), 2, 1);

    // center
    _drawTile(
        c,
        _getDest(x + destTileSize, y + destTileSize, width: mx, height: my),
        1,
        1);
  }

  Rect _getDest(double x, double y, {double width, double height}) {
    final w = width ?? _destTileSizeDouble;
    final h = height ?? _destTileSizeDouble;
    return Rect.fromLTWH(x, y, w, h);
  }

  double get _tileSizeDouble => tileSize.toDouble();

  double get _destTileSizeDouble => destTileSize.toDouble();

  void _drawTile(Canvas c, Rect dest, int i, int j) {
    final xSrc = sprite.src.left + _tileSizeDouble * i;
    final ySrc = sprite.src.top + _tileSizeDouble * j;
    final src = Rect.fromLTWH(xSrc, ySrc, _tileSizeDouble, _tileSizeDouble);
    c.drawImageRect(sprite.image, src, dest, BasicPalette.white.paint);
  }
}
