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

  TiledComponent(this.filename) {
    this.future = _load();
  }

  Future _load() async {
    this.map = await _loadMap();
    this.image = await Flame.images
        .load(map.tilesets[0].images[0].source);
  }

  Future<TileMap> _loadMap() {
    return Flame.bundle
        .loadString('assets/tiles/' + filename)
        .then((contents) {
      var parser = new TileMapParser();
      return parser.parse(contents);
    });
  }

  @override
  void render(Canvas c) {
    if (image == null) {
      return;
    }
    Paint paint = new Paint()..color = Colors.white;
    c.drawImage(image, Offset(0, 0), paint);
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}