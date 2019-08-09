import 'dart:async';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:tiled/tiled.dart' hide Image;

class TiledComponent extends Component {
  String filename;
  TileMap map;
  Image image;
  Map<String, Image> images = <String, Image>{};
  Future future;
  bool _loaded = false;

  static Paint paint = Paint()..color = Colors.white;

  TiledComponent(this.filename) {
    future = _load();
  }

  Future _load() async {
    map = await _loadMap();
    image = await Flame.images.load(map.tilesets[0].image.source);
    images = await _loadImages(map);
    _loaded = true;
  }

  Future<TileMap> _loadMap() {
    return Flame.bundle.loadString('assets/tiles/' + filename).then((contents) {
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
    layer.tiles.forEach((tile) {
      if (tile.gid == 0) {
        return;
      }

      final image = images[tile.image.source];

      final rect = tile.computeDrawRect();
      final src =
          Rect.fromLTWH(rect.left.toDouble(), rect.top.toDouble(), rect.width.toDouble(), rect.height.toDouble());
      final dst = Rect.fromLTWH(tile.x.toDouble(), tile.y.toDouble(), rect.width.toDouble(), rect.height.toDouble());

      c.drawImageRect(image, src, dst, paint);
    });
  }

  @override
  void update(double t) {}

  Future<ObjectGroup> getObjectGroupFromLayer(String name) {
    return future.then((onValue) {
      return map.objectGroups.firstWhere((objectGroup) => objectGroup.name == name);
    });
  }
}
