import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:tiled/tiled.dart' hide Image;

/// Tiled represents all flips and rotation using three possible flips: horizontal, vertical and diagonal.
/// This class converts that representation to a simpler one, that uses one angle (with pi/2 steps) and two flips (H or V).
class _SimpleFlips {
  // angle (in steps of pi/2 rads), clockwise
  final int angle;
  // whether to flip across a central vertical axis.
  final bool flipH;
  // whether to flip across a central horizontal axis.
  final bool flipV;

  _SimpleFlips(this.angle, this.flipH, this.flipV);

  // This is the conversion
  factory _SimpleFlips.fromFlips(Flips flips) {
    int angle;
    bool flipV, flipH;

    if (!flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 0;
      flipV = false;
      flipH = false;
    } else if (!flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 0;
      flipV = false;
      flipH = true;
    } else if (!flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 0;
      flipV = true;
      flipH = false;
    } else if (!flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 2;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 1;
      flipV = false;
      flipH = true;
    } else if (flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 1;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 3;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 1;
      flipV = true;
      flipH = false;
    } else {
      // this should be exhaustive
      throw 'Invalid combination of booleans: $flips';
    }

    return _SimpleFlips(angle, flipH, flipV);
  }
}

class TiledComponent extends Component {
  String filename;
  TileMap map;
  Image image;
  Map<String, Image> images = <String, Image>{};
  Future future;
  bool _loaded = false;
  double destTileSize;

  static Paint paint = Paint()..color = Colors.white;

  TiledComponent(this.filename, this.destTileSize) {
    future = _load();
  }

  Future _load() async {
    map = await _loadMap();
    image = await Flame.images.load(map.tilesets[0].image.source);
    images = await _loadImages(map);
    _loaded = true;
  }

  Future<TileMap> _loadMap() {
    return Flame.bundle.loadString('assets/tiles/$filename').then((contents) {
      final parser = TileMapParser();
      return parser.parse(contents);
    });
  }

  Future<Map<String, Image>> _loadImages(TileMap map) async {
    final Map<String, Image> result = {};
    await Future.forEach(map.tilesets, (tileset) async {
      await Future.forEach(tileset.images, (tmxImage) async {
        result[tmxImage.source] = await Flame.images.load(tmxImage.source);
      });
    });
    return result;
  }

  @override
  bool loaded() => _loaded;

  @override
  void render(Canvas c) {
    if (!loaded()) {
      return;
    }

    map.layers.forEach((layer) {
      if (layer.visible) {
        _renderLayer(c, layer);
      }
    });
  }

  void _renderLayer(Canvas c, Layer layer) {
    layer.tiles.forEach((tileRow) {
      tileRow.forEach((tile) {
        if (tile.gid == 0) {
          return;
        }

        final image = images[tile.image.source];

        final rect = tile.computeDrawRect();
        final src = Rect.fromLTWH(
          rect.left.toDouble(),
          rect.top.toDouble(),
          rect.width.toDouble(),
          rect.height.toDouble(),
        );
        final dst = Rect.fromLTWH(
          tile.x * destTileSize,
          tile.y * destTileSize,
          destTileSize,
          destTileSize,
        );

        final flips = _SimpleFlips.fromFlips(tile.flips);
        c.save();
        c.translate(dst.center.dx, dst.center.dy);
        c.rotate(flips.angle * math.pi / 2);
        c.scale(flips.flipV ? -1.0 : 1.0, flips.flipH ? -1.0 : 1.0);
        c.translate(-dst.center.dx, -dst.center.dy);

        c.drawImageRect(image, src, dst, paint);
        c.restore();
      });
    });
  }

  @override
  void update(double t) {}

  Future<ObjectGroup> getObjectGroupFromLayer(String name) {
    return future.then((onValue) {
      return map.objectGroups
          .firstWhere((objectGroup) => objectGroup.name == name);
    });
  }
}
