import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/component.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

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

abstract class GameWidget extends StatelessWidget implements Component {
  void update(double t);

  void render(Canvas canvas);

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Directionality(
            textDirection: TextDirection.ltr,
            child: new GameRenderObjectWidget(this)));
  }
}

class GameRenderObjectWidget extends SingleChildRenderObjectWidget {
  Component component;

  GameRenderObjectWidget(this.component);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      new GameRenderBox(context, this.component);
}

class GameRenderBox extends RenderBox {
  BuildContext context;

  Component component;

  int _frameCallbackId;

  Duration previous = Duration.ZERO;

  GameRenderBox(this.context, this.component);

  bool get sizedByParent => true;

  void performLayout() {
    // TODO: notify game?
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scheduleTick();
  }

  @override
  void detach() {
    super.detach();
    _unscheduleTick();
  }

  void _scheduleTick() {
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
  }

  void _unscheduleTick() {
    SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId);
  }

  void _tick(Duration timestamp) {
    if (!attached) return;
    _scheduleTick();
    _update(timestamp);
    markNeedsPaint();
  }

  void _update(Duration now) {
    component.update(_computeDeltaT(now));
  }

  double _computeDeltaT(Duration now) {
    Duration delta = now - previous;
    if (previous == Duration.ZERO) {
      delta = Duration.ZERO;
    }
    previous = now;
    var t = delta.inMicroseconds / Duration.MICROSECONDS_PER_SECOND;
    return t;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    component.render(context.canvas);
  }
}
