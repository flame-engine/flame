import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:tmx/tmx.dart' show TileMap, TileMapParser;

class TiledComponent extends Component {
  String filename;
  TileMap map;
  Image image;
  Future future;

  static Paint paint = new Paint()..color = Colors.white;

  TiledComponent(this.filename) {
    this.future = _load();
  }

  Future _load() async {
    this.map = await _loadMap();
    this.image = await Flame.images.load(map.tilesets[0].image.source);
  }

  Future<TileMap> _loadMap() {
    return Flame.bundle.loadString('assets/tiles/' + filename).then((contents) {
      var parser = new TileMapParser();
      return parser.parse(contents);
    });
  }

  bool loaded() => image != null;

  @override
  void render(Canvas c) {
    if (!loaded()) {
      return;
    }

    map.layers[0].tiles.forEach((tile) {
      var rect = tile.computeDrawRect();
      var src = Rect.fromLTWH(rect.left.toDouble(), rect.top.toDouble(),
          rect.width.toDouble(), rect.height.toDouble());
      var dst = Rect.fromLTWH(tile.x.toDouble(), tile.y.toDouble(),
          rect.width.toDouble(), rect.height.toDouble());
      c.drawImageRect(image, src, dst, paint);
    });
    // c.drawImage(image, Offset(0, 110), paint);
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}
