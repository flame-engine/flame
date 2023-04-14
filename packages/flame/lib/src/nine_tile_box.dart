import 'dart:ui';

import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/palette.dart';
import 'package:flame/src/sprite.dart';
import 'package:meta/meta.dart';

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

  @visibleForTesting
  late Rect center;
  
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
    center = Rect.fromLTWH(centerEdge, centerEdge, centerEdge, centerEdge);
    _dst = Rect.fromLTWH(0, 0, this.destTileSize * 3, this.destTileSize * 3);
  }

  /// Creates a nine-box instance with the specified grid size
  ///
  /// The outside columns and rows can be specified with fixed width or height.
  /// The center column and row take up the remaining space.
  NineTileBox.withGrid(this.sprite, {int leftColumnWidth = 0,
      int rightColumnWidth = 0, int topRowHeight = 0,
      int bottomRowHeight = 0,}) : tileSize = sprite.src.width ~/ 3 {
    destTileSize = tileSize;
    center = Rect.fromLTWH(0, 0, sprite.src.width, sprite.src.height);
    _dst = Rect.fromLTWH(0, 0, sprite.src.width, sprite.src.height);
    setGrid(
      leftColumnWidth: leftColumnWidth,
      rightColumnWidth: rightColumnWidth,
      topRowHeight: topRowHeight,
      bottomRowHeight: bottomRowHeight,
    );
  }

  /// Set different sizes for each of the fixed size rows and columns
  ///
  /// The outside columns and rows can be specified with fixed width or height.
  /// The center column and row take up the remaining space. Any values that are
  /// not specified will remain unchanged.
  void setGrid({int? leftColumnWidth, int? rightColumnWidth,
      int? topRowHeight, int? bottomRowHeight,}) {
    if (leftColumnWidth != null && rightColumnWidth != null) {
      assert(
        leftColumnWidth + rightColumnWidth <= sprite.src.width,
        'The left and right columns ($leftColumnWidth + $rightColumnWidth) do '
        'not fit in the width of the sprite (${sprite.src.width.round()})',
      );
    } else if (leftColumnWidth != null) {
      assert(
        leftColumnWidth <= center.right,
        'The left column ($leftColumnWidth) is too large '
        '(max ${center.right.round()})',
      );
    } else if (rightColumnWidth != null) {
      assert(
        rightColumnWidth + center.left <= sprite.src.width,
        'The right column ($rightColumnWidth) is too large '
        '(max ${(sprite.src.width - center.left).round()})',
      );
    }
    if (topRowHeight != null && bottomRowHeight != null) {
      assert(
        topRowHeight + bottomRowHeight <= sprite.src.height,
        'The top and bottom rows ($topRowHeight + $bottomRowHeight) do not fit '
        'in the height of the sprite (${sprite.src.height.round()})',
      );
    } else if (topRowHeight != null) {
      assert(
        topRowHeight <= center.bottom,
        'The top row ($topRowHeight) is too large '
        '(max ${center.bottom.round()})',
      );
    } else if (bottomRowHeight != null) {
      assert(
        bottomRowHeight + center.top <= sprite.src.height,
        'The bottom row ($bottomRowHeight) is too large '
        '(max ${(sprite.src.height - center.top).round()})',
      );
    }

    final left = leftColumnWidth ?? center.left.round();
    final top = topRowHeight ?? center.top.round();
    late final int right;
    if (rightColumnWidth == null) {
      right = center.right.round();
    } else {
      right = sprite.src.width.round() - rightColumnWidth;
    }
    late final int bottom;
    if (bottomRowHeight == null) {
      bottom = center.bottom.round();
    } else {
      bottom = sprite.src.height.round() - bottomRowHeight;
    }
    center = Rect.fromLTRB(
      left.toDouble(),
      top.toDouble(),
      right.toDouble(),
      bottom.toDouble(),
    );
  }

  /// Renders this nine box with the dimensions provided by [dst].
  void drawRect(Canvas c, [Rect? dst]) {
    c.drawImageNine(sprite.image, center, dst ?? _dst, _whitePaint);
  }

  /// Renders this nine box as a rectangle at [position] with size [size].
  void draw(Canvas c, Vector2 position, Vector2 size) {
    c.drawImageNine(
      sprite.image,
      center,
      Rect.fromLTWH(position.x, position.y, size.x, size.y),
      _whitePaint,
    );
  }
}
