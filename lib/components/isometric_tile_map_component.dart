import 'dart:ui';

import 'package:flame/components/component.dart';

import '../flame.dart';
import '../position.dart';
import '../sprite.dart';

class IsometricTileset {
  final Image tileset;
  final int size;

  final Map<int, Sprite> _spriteCache = {};

  IsometricTileset(this.tileset, this.size);

  int get cols => tileset.width ~/ size;

  Sprite getTile(int tileId) {
    return _spriteCache[tileId] ??= _computeTile(tileId);
  }

  Sprite _computeTile(int tileId) {
    final i = tileId % cols;
    final j = tileId ~/ cols;
    final s = size.toDouble();
    return Sprite.fromImage(tileset, x: s * i, y: s * j, width: s, height: s);
  }

  static Future<IsometricTileset> load(String fileName, int size) async {
    final image = await Flame.images.load(fileName);
    return IsometricTileset(image, size);
  }
}

class IsometricTileMapComponent extends PositionComponent {
  IsometricTileset tileset;
  List<List<int>> matrix;
  int destTileSize;

  IsometricTileMapComponent(this.tileset, this.matrix, {this.destTileSize});

  int get effectiveTileSize => destTileSize ?? tileset.size;

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    final s = effectiveTileSize.toDouble();
    matrix.asMap().forEach((i, line) {
      line.asMap().forEach((j, element) {
        if (element == -1) {
          return;
        }

        final sprite = tileset.getTile(element);
        sprite.renderPosition(c, Position(j * s, i * s));
      });
    });
  }
}
