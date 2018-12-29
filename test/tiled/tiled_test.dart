import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:tmx/tmx.dart';

void main() {
  test('my first widget test', () async {
    // Flame.initialize(new TestAssetBundle());
    // var tiled = new TiledComponent('x');
    // await tiled.future;
    expect(1, equals(1));
  });
}

class TiledComponent extends Component {
  String filename;
  Future future;

  TiledComponent(this.filename) {
    this.future = _load();
  }

  Future _load() async {
    await Flame.bundle.loadString('/assets/tiles/' + filename).then((contents) {
      var parser = new TileMapParser();
      TileMap map = parser.parse(contents);
      var x = map.tilesets[0].images[0];
      print('images: ${x.source}');
      // Flame.images.load('x.png', prefix: 'tiles');
    });
  }

  @override
  void render(Canvas c) {
    // TODO: implement render
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    print('load :$key');
    if (key == 'resources/test')
      return ByteData.view(
          Uint8List.fromList(utf8.encode('Hello World!')).buffer);
    return null;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    print('loadString :$key');
    return new File('test/tiled/assets/map.tmx').readAsString();
  }
}
