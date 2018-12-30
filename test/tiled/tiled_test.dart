import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:test/test.dart';
import 'package:tmx/tmx.dart' show TileMap, TileMapParser;

void main() {
  test('my first widget test', () async {
    Flame.initialize(new TestAssetBundle());
    var tiled = new TiledComponent('x');
    await tiled.future;
    expect(1, equals(1));
  });
}

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
        .load(map.tilesets[0].images[0].source, prefix: 'tiles');
  }

  Future<TileMap> _loadMap() {
    return Flame.bundle
        .loadString('/assets/tiles/' + filename)
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

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      new File('test/tiled/assets/map-level1.png')
          .readAsBytes()
          .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      new File('test/tiled/assets/map.tmx').readAsString();
}
