import 'package:flame/flame.dart';
import 'package:flutter/widgets.dart';

import 'dynamic-joystick.dart';
import 'static-joystick.dart';

void main() {
  Flame.initializeWidget();
  Flame.util.setPortraitUpOnly();
  Flame.util.fullScreen();

  runApp(DynamicJoystickGame().widget);
  // runApp(StaticJoystickGame().widget);
  // I'm sure someone can also implement a Tapable Joystick, I haven't tried yet
}
