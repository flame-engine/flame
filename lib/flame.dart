library flame;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'assets/assets_cache.dart';
import 'assets/images.dart';
import 'util.dart';

/// This class holds static references to some useful objects to use in your game.
///
/// You can access shared instances of [AssetsCache], [Images] and [Util].
/// Most games should need only one instance of each, and should use this class to manage that reference.
class Flame {
  // Flame asset bundle, defaults to root
  static AssetBundle _bundle;

  static AssetBundle get bundle => _bundle == null ? rootBundle : _bundle;

  /// Access a shared instance of [AssetsCache] class.
  static AssetsCache assets = AssetsCache();

  /// Access a shared instance of the [Images] class.
  static Images images = Images();

  /// Access a shared instance of the [Util] class.
  static Util util = Util();

  static Future<void> init({
    AssetBundle bundle,
    bool fullScreen = true,
    DeviceOrientation orientation,
  }) async {
    initializeWidget();

    if (fullScreen) {
      await util.fullScreen();
    }

    if (orientation != null) {
      await util.setOrientation(orientation);
    }

    _bundle = bundle;
  }

  static void initializeWidget() {
    WidgetsFlutterBinding.ensureInitialized();
  }
}
