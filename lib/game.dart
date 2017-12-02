import 'dart:typed_data';
import 'dart:ui';

import 'components/component.dart';
import 'flame.dart';
import 'package:flutter/gestures.dart';

abstract class Game {
  void update(double t);

  void render(Canvas canvas);

  start() {
    var previous = Duration.ZERO;

    window.onBeginFrame = (now) {
      var recorder = new PictureRecorder();
      var canvas = new Canvas(
          recorder,
          new Rect.fromLTWH(
              0.0, 0.0, window.physicalSize.width, window.physicalSize.height));

      Duration delta = now - previous;
      if (previous == Duration.ZERO) {
        delta = Duration.ZERO;
      }
      previous = now;

      var t = delta.inMicroseconds / Duration.MICROSECONDS_PER_SECOND;

      update(t);
      render(canvas);

      var deviceTransform = new Float64List(16)
        ..[0] = window.devicePixelRatio
        ..[5] = window.devicePixelRatio
        ..[10] = 1.0
        ..[15] = 1.0;

      var builder = new SceneBuilder()
        ..pushTransform(deviceTransform)
        ..addPicture(Offset.zero, recorder.endRecording())
        ..pop();

      window.render(builder.build());
      window.scheduleFrame();
    };

    window.scheduleFrame();
  }

}

class BaseGame extends Game {

  List<Component> components = new List();

  @override
  void start() {
    Flame.initialize();
    super.start();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) {
      comp.render(canvas);
      canvas.restore();
      canvas.save();
    });
  }

  @override
  void update(double t) {
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
  }
}