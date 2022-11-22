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

      await game.add(lottieComponent);
      await game.ready();

      expect(game.children, isNotEmpty);
      expect(game.children, [lottieComponent]);
    },
  );

  testWithFlameGame(
    'Load composition as AssetBundle and use loadLottie function by library',
    (game) async {
      final logoData =
          Future.value(bytesForFile('example/assets/LottieLogo1.json'));

      final mockAsset = FakeAssetBundle({'logo.json': logoData});

      LottieComposition? composition;

      final asset = Lottie.asset(
        'logo.json',
        bundle: mockAsset,
        onLoaded: (c) {
          composition = c;
        },
      );

      composition = await loadLottie(asset);

      await game.ready();

      expect(composition, isNotNull);
      expect(
        composition!.duration,
        const Duration(seconds: 5, milliseconds: 966),
      );
    },
  );
}

ByteData bytesForFile(String path) =>
    File(path).readAsBytesSync().buffer.asByteData();

class FakeAssetBundle extends Fake implements AssetBundle {
  final Map<String, Future<ByteData>> data;

  FakeAssetBundle(this.data);

  @override
  Future<ByteData> load(String key) {
    return data[key] ?? (Future.error('Asset $key not found'));
  }
}
