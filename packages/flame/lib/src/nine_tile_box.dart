import 'dart:ui';

import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/palette.dart';
import 'package:flame/src/sprite.dart';

/// This allows you to create a rectangle textured with a 9-sliced image.
///
/// How it works is that you have a template image in a 3x3 grid, made up of 9
/// tiles, and a new rectangle can be draw by keeping the 4 corners, expanding
/// the 4 sides only in the direction in which they are located and expanding
/// the center in both directions.
/// That allows you to have non distorted borders.
class NineTileBox {
  static final _whitePaint = BasicPalette.white.paint();

  /// The sprite used to render the box, must be a 3x3 grid of square tiles.
  final Sprite sprite;

  /// The size of each tile in the source sprite image.
  final int tileSize;

  /// The size each tile becomes when rendered
  /// (optionally used to scale the src image).
  late int destTileSize;

  late final Rect _center;
  late final Rect _dst;

  /// Creates a nine-box instance.
  ///
  /// [sprite] is the 3x3 grid and [tileSize] is the size of each tile.
  /// The src sprite must be a square of size 3*[tileSize].
  ///
  /// If [tileSize] is not provided, the width of the sprite is assumed as the
  /// size. Otherwise the width and height properties of the sprite are ignored.
  ///
  /// If [destTileSize] is not provided, the evaluated [tileSize] is used
  /// instead (so no scaling happens).
  NineTileBox(this.sprite, {int? tileSize, int? destTileSize})
      : tileSize = tileSize ?? sprite.src.width ~/ 3 {
    this.destTileSize = destTileSize ?? this.tileSize;
    final centerEdge = this.tileSize.toDouble();
    _center = Rect.fromLTWH(centerEdge, centerEdge, centerEdge, centerEdge);
    _dst = Rect.fromLTWH(0, 0, this.destTileSize * 3, this.destTileSize * 3);
  }

  /// Renders this nine box with the dimensions provided by [dst].
  void drawRect(Canvas c, [Rect? dst]) {
    c.drawImageNine(sprite.image, _center, dst ?? _dst, _whitePaint);
  }

  /// Renders this nine box as a rectangle at [position] with size [size].
  void draw(Canvas c, Vector2 position, Vector2 size) {
    c.drawImageNine(
      sprite.image,
      _center,
      Rect.fromLTWH(position.x, position.y, size.x, size.y),
      _whitePaint,
    );
  }
}
