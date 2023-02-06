import 'package:flame_studio/src/widgets/flame_studio.dart';
import 'package:flutter/widgets.dart';

void runFlameStudio(Widget app, {bool enabled = true}) {
  var allowRun = true;
  assert(() {
    if (enabled) {
      runApp(FlameStudio(app));
      allowRun = false;
    }
    return true;
  }());
  if (allowRun) {
    runApp(app);
  }
}
