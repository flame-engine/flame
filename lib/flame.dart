library flame;

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'assets_cache.dart';
import 'bgm.dart';
import 'flame_audio.dart';
import 'images.dart';
import 'util.dart';

/// This class holds static references to some useful objects to use in your game.
///
/// You can access shared instances of [AudioCache], [Images] and [Util].
/// Most games should need only one instance of each, and should use this class to manage that reference.
class Flame {
  // Flame asset bundle, defaults to root
  static AssetBundle _bundle;
  static AssetBundle get bundle => _bundle == null ? rootBundle : _bundle;

  /// Access a shared instance of the [FlameAudio] class.
  static FlameAudio audio = FlameAudio();

  /// Access a shared instance of the [Bgm] class.
  static Bgm _bgm;
  static Bgm get bgm => _bgm ??= Bgm();

  /// Access a shared instance of the [Images] class.
  static Images images = Images();

  /// Access a shared instance of the [Util] class.
  static Util util = Util();

  /// Access a shard instance of [AssetsCache] class.
  static AssetsCache assets = AssetsCache();

  static Future<void> init(
      {AssetBundle bundle,
      bool fullScreen = true,
      DeviceOrientation orientation}) async {
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
