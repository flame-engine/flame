import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

class RawKeyboardExample extends FlameGame with RawKeyboardDetector {
  static String description = '';

  @override
  void onRawKeyEvent(RawKeyEvent event) {
    print(physicalKeysPressed);
  }
}
