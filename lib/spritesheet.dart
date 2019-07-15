import 'sprite.dart';
import 'animation.dart';

/// Utility class to help extract animations and sprites from a spritesheet image
class SpriteSheet {
  String imageName;
  int textureWidth;
  int textureHeight;
  int columns;
  int rows;

  List<List<Sprite>> _sprites;

  SpriteSheet(
      {this.imageName,
      this.textureWidth,
      this.textureHeight,
      this.columns,
      this.rows}) {
    _sprites = List.generate(
        rows,
        (y) => List.generate(
            columns,
            (x) => Sprite(imageName,
                x: (x * textureWidth).toDouble(),
                y: (y * textureHeight).toDouble(),
                width: textureWidth.toDouble(),
                height: textureHeight.toDouble())));
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
