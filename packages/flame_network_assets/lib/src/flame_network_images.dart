import 'dart:ui';

import 'package:flame_network_assets/flame_network_assets.dart';
import 'package:flutter/rendering.dart';

/// {@template flame_network_images}
/// A specialized [FlameAssetResponse] that can be used to load [Image]s.
///
/// {@macro flame_network_assets}
///
/// {@endtemplate}
class FlameNetworkImages extends FlameNetworkAssets<Image> {
  /// {@macro flame_network_images}
  FlameNetworkImages({
    super.get,
    super.getAppDirectory,
    super.cacheInMemory,
    super.cacheInStorage,
  }) : super(
         decodeAsset: decodeImageFromList,
         encodeAsset: (Image image) async {
           final data = await image.toByteData(format: ImageByteFormat.png);

           return data!.buffer.asUint8List();
         },
       );
}
