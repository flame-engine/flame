import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:test/test.dart';

void main() {
  test('correct loads the file', () async {
    Flame.bundle = TestAssetBundle();
    final tiled = await TiledComponent.load('x', Vector2.all(16));
    expect(tiled.tileMap.batches, isNotEmpty);
  });
}

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return File('test/assets/map-level1.png')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return File('test/assets/map.tmx').readAsString();
  }
}
