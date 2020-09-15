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

class Block {
  int x, y;
  Block(this.x, this.y);

  @override
  String toString() => '($x, $y)';
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

    final size = Position.fromInts(effectiveTileSize, effectiveTileSize);
    matrix.asMap().forEach((i, line) {
      line.asMap().forEach((j, element) {
        if (element == -1) {
          return;
        }

        final sprite = tileset.getTile(element);
        final p = getBlockPositionInts(j, i);
        sprite.renderRect(c, Position.rectFrom(p, size));
      });
    });
  }

  Position getBlockPosition(Block block) {
    return getBlockPositionInts(block.x, block.y);
  }

  Position getBlockPositionInts(int i, int j) {
    final s = effectiveTileSize.toDouble() / 2;
    return cartToIso(Position(i * s, j * s)).minus(Position(s, 0));
  }

  Position isoToCart(Position p) {
    final x = (2 * p.y + p.x) / 2;
    final y = (2 * p.y - p.x) / 2;
    return Position(x, y);
  }

  Position cartToIso(Position p) {
    final x = p.x - p.y;
    final y = (p.x + p.y) / 2;
    return Position(x, y);
  }

  Block getBlock(Position p) {
    final s = effectiveTileSize.toDouble() / 2;
    final cart = isoToCart(p.clone().minus(toPosition()));
    final px = cart.x ~/ s;
    final py = cart.y ~/ s;
    return Block(px, py);
  }

  bool containsBlock(Block block) {
    return block.x >= 0 &&
        block.x < matrix.length &&
        block.y >= 0 &&
        block.y < matrix[block.x].length;
  }
}
