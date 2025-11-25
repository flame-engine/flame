import 'dart:io';
import 'dart:typed_data';

import 'package:flame_lottie/flame_lottie.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWithFlameGame(
    'Game holds LottieComponent',
    (game) async {
      // When running tests we have to sync read the file and can not use the
      // recommended [loadLottie] function.
      final data = File('example/assets/LottieLogo1.json').readAsBytesSync();
      final composition = await LottieComposition.fromBytes(data);

      final lottieComponent = LottieComponent(composition);

      await game.world.add(lottieComponent);
      await game.ready();

      expect(game.world.children, [lottieComponent]);
    },
  );

  testWithFlameGame(
    'Load composition as AssetBundle and use loadLottie function by library',
    (game) async {
      final logoData = Future.value(
        _bytesForFile('example/assets/LottieLogo1.json'),
      );

      final mockAsset = _FakeAssetBundle({'logo.json': logoData});

      final asset = Lottie.asset(
        'logo.json',
        bundle: mockAsset,
      );

      final composition = await loadLottie(asset);

      await game.ready();

      expect(
        composition.duration,
        const Duration(seconds: 5, milliseconds: 966),
      );
    },
  );
}

ByteData _bytesForFile(String path) =>
    File(path).readAsBytesSync().buffer.asByteData();

class _FakeAssetBundle extends Fake implements AssetBundle {
  final Map<String, Future<ByteData>> data;

  _FakeAssetBundle(this.data);

  @override
  Future<ByteData> load(String key) {
    return data[key] ?? (Future.error('Asset $key not found'));
  }
}
