import 'dart:ui';

import 'extensions/vector2.dart';
import 'sprite.dart';
import 'sprite_animation.dart';

/// Utility class to help extract animations and sprites from a sprite sheet image.
///
/// A sprite sheet is a single image in which several regions can be defined as individual sprites.
/// For the purposes of this class, all of these regions must be identically sized rectangles.
/// You can use the [Sprite] class directly if you want to have varying shapes.
///
/// Each sprite in this sheet can be identified either by it's (row, col) pair or
/// by it's "id", which is basically it's sequenced index if the image is put in a
/// single line. The sprites can be used to compose an animation easily if they
/// all the frames happen to be sequentially on the same row.
/// Sprites are lazily generated but cached.
class SpriteSheet {
  /// The src image from which each sprite will be generated.
  final Image image;

  /// The size of each rectangle within the image that define each sprite.
  ///
  /// For example, if this sprite sheet is a tile map, this would be the tile size.
  /// If it's an animation sheet, this would be the frame size.
  final Vector2 srcSize;

  final Map<int, Sprite> _spriteCache = {};

  /// Creates a sprite sheet given the image and the tile size.
  SpriteSheet({
    required this.image,
    required this.srcSize,
  });

  SpriteSheet.fromColumnsAndRows({
    required this.image,
    required int columns,
    required int rows,
  }) : srcSize = Vector2(
          image.width / columns,
          image.height / rows,
        );

  /// Compute the number of columns the image has
  /// by using the image width and tile size.
  int get columns => image.width ~/ srcSize.x;

  /// Compute the number of rows the image has
  /// by using the image height and tile size.
  int get rows => image.height ~/ srcSize.y;

  /// Gets the sprite in the position (row, column) on the sprite sheet grid.
  ///
  /// This is lazily computed and cached for your convenience.
  Sprite getSprite(int row, int column) {
    return getSpriteById(row * columns + column);
  }

  /// Gets teh sprite with id [spriteId] from the grid.
  ///
  /// The ids are defined as starting at 0 on the top left and going
  /// sequentially on each row.
  /// This is lazily computed and cached for your convenience.
  Sprite getSpriteById(int spriteId) {
    return _spriteCache[spriteId] ??= _computeSprite(spriteId);
  }

  Sprite _computeSprite(int spriteId) {
    final i = spriteId % columns;
    final j = spriteId ~/ columns;
    return Sprite(
      image,
      srcPosition: Vector2Extension.fromInts(i, j)..multiply(srcSize),
      srcSize: srcSize,
    );
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
    to ??= columns;

    final spriteList = List<int>.generate(to - from, (i) => from + i)
        .map((e) => getSprite(row, e))
        .toList();

    return SpriteAnimation.spriteList(
      spriteList,
      stepTime: stepTime,
      loop: loop,
    );
  }
}
