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
  /// A nine-box is a grid with 3 rows and 3 columns. The outer-most columns,
  /// [leftWidth] and [rightWidth], are a fixed-width. As the nine-box is
  /// resized, those columns remain fixed-width and the center column stretches
  /// to take up the remaining space. In the same way, the outer-most rows,
  /// [topHeight] and [bottomHeight], are a fixed-height. As the nine-box is
  /// resized, those rows remain fixed-height and the center row stretches
  /// to take up the remaining space.
  NineTileBox.withGrid(
    this.sprite, {
    double leftWidth = 0.0,
    double rightWidth = 0.0,
    double topHeight = 0.0,
    double bottomHeight = 0.0,
  }) : tileSize = sprite.src.width ~/ 3 {
    destTileSize = tileSize;
    center = Rect.fromLTWH(0, 0, sprite.src.width, sprite.src.height);
    _dst = Rect.fromLTWH(0, 0, sprite.src.width, sprite.src.height);
    setGrid(
      leftWidth: leftWidth,
      rightWidth: rightWidth,
      topHeight: topHeight,
      bottomHeight: bottomHeight,
    );
  }

  /// Set different sizes for each of the fixed size rows and columns
  ///
  /// A nine-box is a grid with 3 rows and 3 columns. The outer-most columns,
  /// [leftWidth] and [rightWidth], are a fixed-width. As the nine-box is
  /// resized, those columns remain fixed-width and the center column stretches
  /// to take up the remaining space. In the same way, the outer-most rows,
  /// [topHeight] and [bottomHeight], are a fixed-height. As the nine-box is
  /// resized, those rows remain fixed-height and the center row stretches
  /// to take up the remaining space.
  ///
  /// Any widths or heights that are not specified remain unchanged.
  void setGrid({
    double? leftWidth,
    double? rightWidth,
    double? topHeight,
    double? bottomHeight,
  }) {
    if (leftWidth != null && rightWidth != null) {
      assert(
        leftWidth + rightWidth <= sprite.src.width,
        'The left and right columns ($leftWidth + $rightWidth) do '
        'not fit in the width of the sprite (${sprite.src.width})',
      );
    } else if (leftWidth != null) {
      assert(
        leftWidth <= center.right,
        'The left column ($leftWidth) is too large '
        '(max ${center.right})',
      );
    } else if (rightWidth != null) {
      assert(
        rightWidth + center.left <= sprite.src.width,
        'The right column ($rightWidth) is too large '
        '(max ${sprite.src.width - center.left})',
      );
    }
    if (topHeight != null && bottomHeight != null) {
      assert(
        topHeight + bottomHeight <= sprite.src.height,
        'The top and bottom rows ($topHeight + $bottomHeight) do not fit '
        'in the height of the sprite (${sprite.src.height})',
      );
    } else if (topHeight != null) {
      assert(
        topHeight <= center.bottom,
        'The top row ($topHeight) is too large '
        '(max ${center.bottom})',
      );
    } else if (bottomHeight != null) {
      assert(
        bottomHeight + center.top <= sprite.src.height,
        'The bottom row ($bottomHeight) is too large '
        '(max ${sprite.src.height - center.top})',
      );
    }

    final left = leftWidth ?? center.left;
    final top = topHeight ?? center.top;
    late final double right;
    if (rightWidth == null) {
      right = center.right;
    } else {
      right = sprite.src.width - rightWidth;
    }
    late final double bottom;
    if (bottomHeight == null) {
      bottom = center.bottom;
    } else {
      bottom = sprite.src.height - bottomHeight;
    }
    center = Rect.fromLTRB(
      left,
      top,
      right,
      bottom,
    );
  }

  /// Renders this nine box with the dimensions provided by [dst].
  void drawRect(Canvas c, [Rect? dst, Paint? overridePaint]) {
    _draw(c, dst ?? _dst, overridePaint ?? _whitePaint);
  }

  /// Renders this nine box as a rectangle at [position] with size [size].
  void draw(Canvas c, Vector2 position, Vector2 size, [Paint? overridePaint]) {
    _draw(
      c,
      Rect.fromLTWH(position.x, position.y, size.x, size.y),
      overridePaint ?? _whitePaint,
    );
  }

  void _draw(Canvas c, Rect dst, Paint paint) {
    final src = sprite.src;
    final isFullImage =
        src.left == 0 &&
        src.top == 0 &&
        src.right == sprite.image.width &&
        src.bottom == sprite.image.height;

    if (isFullImage) {
      c.drawImageNine(sprite.image, center, dst, paint);
    } else {
      _drawTiles(c, dst, paint);
    }
  }

  /// Draws the nine tiles of [sprite] stretched to fill [dst].
  ///
  /// [Canvas.drawImageNine] is not used because it treats the whole
  /// [Sprite.image] as the source, ignoring [Sprite.src].
  void _drawTiles(Canvas c, Rect dst, Paint paint) {
    final srcLeft = sprite.src.left;
    final srcTop = sprite.src.top;
    final srcRight = sprite.src.right;
    final srcBottom = sprite.src.bottom;

    final srcXs = [
      srcLeft,
      center.left + srcLeft,
      center.right + srcLeft,
      srcRight,
    ];

    final srcYs = [
      srcTop,
      center.top + srcTop,
      center.bottom + srcTop,
      srcBottom,
    ];

    final dstXs = [
      dst.left,
      dst.left + center.left,
      dst.right - (sprite.src.width - center.right),
      dst.right,
    ];

    final dstYs = [
      dst.top,
      dst.top + center.top,
      dst.bottom - (sprite.src.height - center.bottom),
      dst.bottom,
    ];

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        c.drawImageRect(
          sprite.image,
          Rect.fromLTRB(
            srcXs[col],
            srcYs[row],
            srcXs[col + 1],
            srcYs[row + 1],
          ),
          Rect.fromLTRB(
            dstXs[col],
            dstYs[row],
            dstXs[col + 1],
            dstYs[row + 1],
          ),
          paint,
        );
      }
    }
  }
}
