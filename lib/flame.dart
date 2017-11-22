library flame;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'audio.dart';
import 'images.dart';
import 'util.dart';

class Flame {
  static Audio audio = new Audio();
  static Images images = new Images();
  static Util util = new Util();

  static void initialize() {
    FlameBiding.ensureInitialized();
  }
}

class FlameBiding extends BindingBase with GestureBinding, ServicesBinding {
  static FlameBiding instance;

  static FlameBiding ensureInitialized() {
    if (FlameBiding.instance == null) new FlameBiding();
    return FlameBiding.instance;
  }
}
