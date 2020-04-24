import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

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

  void _drawRotatedImageRect(canvas, src, dst, image, {double rotate = 0, double scaleX = 1, double scaleY = 1}) {
    canvas.save();
    canvas.translate( dst.center.dx, dst.center.dy );
    canvas.rotate(rotate);
    canvas.scale(scaleX, scaleY);
    canvas.translate( -dst.center.dx, -dst.center.dy );
    canvas.drawImageRect(image, src, dst, paint);
    canvas.restore();
  }

  void _renderLayer(Canvas c, Layer layer) {
    layer.tiles.forEach((tile) {
      if (tile.gid == 0) {
        return;
      }

      final image = images[tile.image.source];

      final rect = tile.computeDrawRect();
      final src = Rect.fromLTWH(rect.left.toDouble(), rect.top.toDouble(),
          rect.width.toDouble(), rect.height.toDouble());
      final dst = Rect.fromLTWH(tile.x.toDouble(), tile.y.toDouble(),
          rect.width.toDouble(), rect.height.toDouble());

      switch(tile.rotation) {
        case 1:
          _drawRotatedImageRect(c, src, dst, image, rotate: (3 * math.pi/2));
          break;
        case 2:
          _drawRotatedImageRect(c, src, dst, image, rotate: math.pi);
          break;
        case 3:
          _drawRotatedImageRect(c, src, dst, image, rotate: math.pi/2);
          break;
        case 4:
          _drawRotatedImageRect(c, src, dst, image, scaleY: -1);
          break;
        case 5:
          _drawRotatedImageRect(c, src, dst, image, rotate: (3 * math.pi/2), scaleY: -1);
          break;
        case 6:
          _drawRotatedImageRect(c, src, dst, image, scaleX: -1);
          break;
        case 7:
          _drawRotatedImageRect(c, src, dst, image, rotate: (3 * math.pi/2), scaleX: -1);
          break;
        default:
          c.drawImageRect(image, src, dst, paint);
          break;
      }
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
