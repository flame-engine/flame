import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'components/component.dart';

abstract class Game {
  void update(double t);

  void render(Canvas canvas);

  void resize(Size size);

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
  final Game game;

  GameRenderObjectWidget(this.game);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      new GameRenderBox(context, this.game);
}

class GameRenderBox extends RenderBox {
  BuildContext context;

  Game game;

  int _frameCallbackId;

  Duration previous = Duration.ZERO;

  GameRenderBox(this.context, this.game);

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    super.performResize();
    game.resize(constraints.biggest);
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

abstract class BaseGame extends Game {
  final List<Component> components = new List();

  @override
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) {
      comp.render(canvas);
      canvas.restore();
      canvas.save();
    });
    canvas.restore();
  }

  @override
  void update(double t) {
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
  }
}
