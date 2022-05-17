library flame;

import 'package:flame/src/cache/assets_cache.dart';
import 'package:flame/src/cache/images.dart';
import 'package:flame/src/device.dart';
import 'package:flutter/services.dart';

/// This class holds static references to some useful objects to use in your
/// game.
///
/// You can access shared instances of [AssetsCache], [Images] and [Device].
/// Most games should need only one instance of each, and should use this class
/// to manage that reference.
class Flame {
  /// Flame asset bundle, defaults to the root bundle but can be globally
  /// changed.
  static AssetBundle bundle = rootBundle;

  /// Access a shared instance of [AssetsCache] class.
  static AssetsCache assets = AssetsCache();

  /// Access a shared instance of the [Images] class.
  static Images images = Images();

  /// Access a shared instance of the [Device] class.
  static Device device = Device();
}
