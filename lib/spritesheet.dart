import 'dart:ui';

import 'package:meta/meta.dart';

import 'animation.dart';
import 'sprite.dart';

/// Utility class to help extract animations and sprites from a spritesheet image
class SpriteSheet {
  int textureWidth;
  int textureHeight;
  int columns;
  int rows;

  List<List<Sprite>> _sprites;

  SpriteSheet({
    @required String imageName,
    @required this.textureWidth,
    @required this.textureHeight,
    @required this.columns,
    @required this.rows,
  }) {
    _sprites = List.generate(
      rows,
      (y) => List.generate(
        columns,
        (x) => _mapImagePath(imageName, textureWidth, textureHeight, x, y),
      ),
    );
  }

  Sprite _mapImagePath(
    String imageName,
    int textureWidth,
    int textureHeight,
    int x,
    int y,
  ) {
    return Sprite(
      imageName,
      x: (x * textureWidth).toDouble(),
      y: (y * textureHeight).toDouble(),
      width: textureWidth.toDouble(),
      height: textureHeight.toDouble(),
    );
  }

  SpriteSheet.fromImage({
    @required Image image,
    @required this.textureWidth,
    @required this.textureHeight,
    @required this.columns,
    @required this.rows,
  }) {
    _sprites = List.generate(
      rows,
      (y) => List.generate(
        columns,
        (x) => _mapImage(image, textureWidth, textureHeight, x, y),
      ),
    );
  }

  Sprite _mapImage(
    Image image,
    int textureWidth,
    int textureHeight,
    int x,
    int y,
  ) {
    return Sprite.fromImage(
      image,
      x: (x * textureWidth).toDouble(),
      y: (y * textureHeight).toDouble(),
      width: textureWidth.toDouble(),
      height: textureHeight.toDouble(),
    );
  }

  Sprite getSprite(int row, int column) {
    final Sprite s = _sprites[row][column];

    assert(s != null, 'No sprite found for row $row and column $column');

    return s;
  }

  /// Creates an animation from this SpriteSheet
  ///
  /// An [from] and a [to]  parameter can be specified to create an animation from a subset of the columns on the row
  Animation createAnimation(int row,
      {double stepTime, bool loop = true, int from = 0, int to}) {
    final spriteRow = _sprites[row];

    assert(spriteRow != null, 'There is no row for $row index');

    to ??= spriteRow.length;

    final spriteList = spriteRow.sublist(from, to);

    return Animation.spriteList(
      spriteList,
      stepTime: stepTime,
      loop: loop,
    );
  }
}
