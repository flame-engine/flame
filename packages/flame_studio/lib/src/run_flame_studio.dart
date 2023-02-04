import 'package:flame_studio/src/framework/flame_studio.dart';
import 'package:flutter/widgets.dart';

void runFlameStudio(Widget app, {bool enabled = true}) {
  assert(() {
    if (enabled) {
      runApp(FlameStudio(app));
    }
    return true;
  }());
  runApp(app);
}
