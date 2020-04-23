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


  void _renderLayer(Canvas c, Layer layer){
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

      //Rotating & Drawing our Tiles
      switch(tile.rotation){
        case 0:
          //0 ° Rotation
          c.drawImageRect(image, src, dst, paint);
          break;
        case 1:
          //90 ° Rotation
          c.save();
          c.translate( dst.center.dx, dst.center.dy );
          c.rotate((3 * math.pi/2));
          c.translate( -dst.center.dx, -dst.center.dy );
          c.drawImageRect(image, src, dst, paint);
          c.restore();
          break;
        case 2:
          //180 ° Rotation
          c.save();
          c.translate( dst.center.dx, dst.center.dy );
          c.rotate(math.pi);
          c.translate( -dst.center.dx, -dst.center.dy );
          c.drawImageRect(image, src, dst, paint);
          c.restore();
          break;
        case 3:
          //270 ° Rotation
          c.save();
          c.translate( dst.center.dx, dst.center.dy );
          c.rotate(math.pi/2);
          c.translate( -dst.center.dx, -dst.center.dy );
          c.drawImageRect(image, src, dst, paint);
          c.restore();
          break;
        case 4:
          //0 ° + Vertical Flip
          c.save();
          c.translate( dst.center.dx, dst.center.dy );
          c.scale(1, -1);
          c.translate( -dst.center.dx, -dst.center.dy );
          c.drawImageRect(image, src, dst, paint);
          c.restore();
          break;
        case 5:
          //90 ° + Vertical Flip
          c.save();
          c.translate( dst.center.dx, dst.center.dy );
          c.rotate((3 * math.pi/2));
          c.scale(1, -1);
          c.translate( -dst.center.dx, -dst.center.dy );
          c.drawImageRect(image, src, dst, paint);
          c.restore();
          break;
        case 6:
          //0 ° + Horizontal Flip
          c.save();
          c.translate( dst.center.dx, dst.center.dy );
          c.scale(-1, 1);
          c.translate( -dst.center.dx, -dst.center.dy );
          c.drawImageRect(image, src, dst, paint);
          c.restore();
          break;
        case 7:
          //90 ° + Horizontal Flip
          c.save();
          c.translate( dst.center.dx, dst.center.dy );
          c.rotate((3 * math.pi/2));
          c.scale(-1, 1);
          c.translate( -dst.center.dx, -dst.center.dy );
          c.drawImageRect(image, src, dst, paint);
          c.restore();
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
