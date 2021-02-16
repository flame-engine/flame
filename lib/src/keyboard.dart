import 'package:flutter/services.dart';

import 'game/game.dart';

mixin KeyboardEvents on Game {
  void onKeyEvent(RawKeyEvent event);
}
