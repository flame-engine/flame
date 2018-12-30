import 'dart:io';
import 'dart:typed_data';

import 'package:flame/flame.dart';
import 'package:flame/tiled/tiled_component.dart';
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:test/test.dart';

void main() {
  test('my first widget test', () async {
    Flame.initialize(new TestAssetBundle());
    var tiled = new TiledComponent('x');
    await tiled.future;
    expect(1, equals(1));
  });
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
