import 'dart:typed_data';
import 'dart:ui';

import 'components/component.dart';
import 'flame.dart';
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

abstract class GameWidget {
  void update(double t);

  void render(Canvas canvas);

  Widget _widget;

  Widget get widget {
    if (_widget == null) {
      _widget = new Center(
          child: new Directionality(
              textDirection: TextDirection.ltr,
              child: new GameRenderObjectWidget(this)));
    }
    return _widget;
  }
}

class GameRenderObjectWidget extends SingleChildRenderObjectWidget {
  GameWidget game;

  GameRenderObjectWidget(this.game);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      new GameRenderBox(context, this.game);
}

class GameRenderBox extends RenderBox {
  BuildContext context;

  GameWidget game;

  int _frameCallbackId;

  Duration previous = Duration.ZERO;

  GameRenderBox(this.context, this.game);

  @override
  bool get sizedByParent => true;

  @override
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
    game.update(_computeDeltaT(now));
  }

  double _computeDeltaT(Duration now) {
    Duration delta = now - previous;
    if (previous == Duration.ZERO) {
      delta = Duration.ZERO;
    }
    previous = now;
    return delta.inMicroseconds / Duration.MICROSECONDS_PER_SECOND;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    game.render(context.canvas);
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
