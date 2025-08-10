import 'dart:ui';

import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/sprite_animation.dart';

/// Utility class to help extract animations and sprites from a sprite sheet
/// image.
///
/// A sprite sheet is a single image in which several regions can be defined as
/// individual sprites.
/// For the purposes of this class, all of these regions must be identically
/// sized rectangles.
/// You can use the [Sprite] class directly if you want to have varying shapes.
///
/// Each sprite in this sheet can be identified either by it's (row, col) pair
/// or by it's "id", which is basically it's sequenced index if the image is put
/// in a single line. The sprites can be used to compose an animation easily if
/// all the frames are sequentially on the same row.
/// Sprites are lazily generated but cached.
class SpriteSheet {
  /// The src image from which each sprite will be generated.
  final Image image;

  /// The size of each rectangle within the image that define each sprite.
  ///
  /// For example, if this sprite sheet is a tile map, this would be the tile
  /// size. If it's an animation sheet, this would be the frame size.
  final Vector2 srcSize;

  /// The empty space around the edges of the image.
  final double margin;

  /// This empty space in between adjacent tiles within the image.
  final double spacing;

  /// The number of rows in the image based on the image height and the tile
  /// size.
  final int rows;

  /// The number of columns in the image based on the image width and the tile
  /// size.
  final int columns;

  final Map<int, Sprite> _spriteCache = {};

  /// Creates a sprite sheet given the image and the tile size.
  SpriteSheet({
    required this.image,
    required this.srcSize,
    this.margin = 0,
    this.spacing = 0,
  }) : columns = (image.width - 2 * margin + spacing) ~/ (srcSize.x + spacing),
       rows = (image.height - 2 * margin + spacing) ~/ (srcSize.y + spacing);

  SpriteSheet.fromColumnsAndRows({
    required this.image,
    required this.columns,
    required this.rows,
    this.spacing = 0,
    this.margin = 0,
  }) : srcSize = Vector2(
         (image.width - 2 * margin - (columns - 1) * spacing) / columns,
         (image.height - 2 * margin - (rows - 1) * spacing) / rows,
       );

  /// Gets the sprite in the position (row, column) on the sprite sheet grid.
  ///
  /// This is lazily computed and cached for your convenience.
  Sprite getSprite(int row, int column) {
    return getSpriteById(row * columns + column);
  }

  /// Gets the sprite with id [spriteId] from the grid.
  ///
  /// The ids are defined as starting at 0 on the top left and going
  /// sequentially on each row.
  /// This is lazily computed and cached for your convenience.
  Sprite getSpriteById(int spriteId) {
    return _spriteCache[spriteId] ??= _computeSprite(spriteId);
  }

  /// Create a [SpriteAnimationFrameData] for the sprite in the position
  /// (row, column) on the sprite sheet grid.
  SpriteAnimationFrameData createFrameData(
    int row,
    int column, {
    required double stepTime,
  }) {
    return createFrameDataFromId(row * columns + column, stepTime: stepTime);
  }

  /// Create a [SpriteAnimationFrameData] for the sprite with id [spriteId]
  /// from the grid.
  ///
  /// The ids are defined as starting at 0 on the top left and going
  /// sequentially on each row.
  SpriteAnimationFrameData createFrameDataFromId(
    int spriteId, {
    required double stepTime,
  }) {
    final i = spriteId % columns;
    final j = spriteId ~/ columns;
    return SpriteAnimationFrameData(
      srcPosition: Vector2Extension.fromInts(i, j)..multiply(srcSize),
      srcSize: srcSize,
      stepTime: stepTime,
    );
  }

  Sprite _computeSprite(int spriteId) {
    final i = spriteId % columns;
    final j = spriteId ~/ columns;
    return Sprite(
      image,
      srcPosition: Vector2Extension.fromInts(i, j)
        ..multiply(srcSize)
        ..translate(margin + i * spacing, margin + j * spacing),
      srcSize: srcSize,
    );
  }

  List<Sprite> _generateSpriteList({
    required int row,
    int from = 0,
    int? to,
  }) {
    to ??= columns;

    return List<int>.generate(
      to - from,
      (i) => from + i,
    ).map((e) => getSprite(row, e)).toList();
  }

  /// Creates a [SpriteAnimation] from this SpriteSheet, using the sequence
  /// of sprites on a given row.
  ///
  /// [from] and [to] can be specified to create an animation
  /// from a subset of the columns on the row
  SpriteAnimation createAnimation({
    required int row,
    required double stepTime,
    bool loop = true,
    int from = 0,
    int? to,
  }) {
    final spriteList = _generateSpriteList(
      row: row,
      to: to,
      from: from,
    );

    return SpriteAnimation.spriteList(
      spriteList,
      stepTime: stepTime,
      loop: loop,
    );
  }

  /// Creates a [SpriteAnimation] from this SpriteSheet, using the sequence
  /// of sprites on a given row with different duration for each.
  ///
  /// [from] and [to] can be specified to create an animation
  /// from a subset of the columns on the row
  SpriteAnimation createAnimationWithVariableStepTimes({
    required int row,
    required List<double> stepTimes,
    bool loop = true,
    int from = 0,
    int? to,
  }) {
    final spriteList = _generateSpriteList(
      row: row,
      to: to,
      from: from,
    );

    return SpriteAnimation.variableSpriteList(
      spriteList,
      loop: loop,
      stepTimes: stepTimes,
    );
  }
}
