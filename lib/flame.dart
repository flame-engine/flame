library flame;

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'images.dart';
import 'util.dart';
import 'gamepad.dart';

export 'gamepad.dart';

/// This class holds static references to some useful objects to use in your game.
///
/// You can access shared instances of [AudioCache], [Images] and [Util].
/// Most games should need only one instance of each, and should use this class to manage that reference.
class Flame {

  /// Access a shared instance of the [AudioCache] class.
  static AudioCache audio = new AudioCache(prefix: 'audio/');

  /// Access a shared instance of the [Images] class.
  static Images images = new Images();

  /// Access a shared instance of the [Util] class.
  static Util util = new Util();

  /// Access a shared instance of the [Gamepad] class.
  static Gamepad gamepad = new Gamepad();

  /// TODO verify if this is still needed (I don't think so)
  static void initialize() {
    FlameBiding.ensureInitialized();
  }

  /// TODO verify if this is still needed (I don't think so)
  static void initializeWidget() {
    WidgetsFlutterBinding.ensureInitialized();
  }
}

/// This class never needs to be used.
///
/// It only exists here in order for [BindingBase] to setup Flutter services.
/// TODO: this could possibly be private, verify if it'd work.
class FlameBiding extends BindingBase with GestureBinding, ServicesBinding {
  static FlameBiding instance;

  static FlameBiding ensureInitialized() {
    if (FlameBiding.instance == null) new FlameBiding();
    return FlameBiding.instance;
  }
}
