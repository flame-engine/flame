import 'dart:ui';
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'components/component.dart';
import 'position.dart';

abstract class Game {
  void update(double t);

  void render(Canvas canvas);

  void resize(Size size);

  void didChangeAppLifecycleState(AppLifecycleState state) {}

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
  RenderObject createRenderObject(BuildContext context) => new GameRenderBox(context, this.game);
}

class GameRenderBox extends RenderBox with WidgetsBindingObserver {
  BuildContext context;

  Game game;

  int _frameCallbackId;

  Duration previous = Duration.zero;

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
    _bindLifecycleListener();
  }

  @override
  void detach() {
    super.detach();
    _unscheduleTick();
    _unbindLifecycleListener();
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
    if (previous == Duration.zero) {
      delta = Duration.zero;
    }
    previous = now;
    return delta.inMicroseconds / Duration.microsecondsPerSecond;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    game.render(context.canvas);
  }

  void _bindLifecycleListener() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _unbindLifecycleListener() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    game.didChangeAppLifecycleState(state);
  }
}

abstract class BaseGame extends Game {

  List<Component> components = [];
  List<Component> _addLater = [];
  Size size;
  Position camera = new Position.empty();

  void add(Component c) {
    this.components.add(c);

    // first time resize
    if (size != null) {
      c.resize(size);
    }
  }

  void addLater(Component c) {
    this._addLater.add(c);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();
  }

  void renderComponent(Canvas canvas, Component c) {
      if (!c.isHud()) {
        canvas.translate(-camera.x, -camera.y);
      }
      c.render(canvas);
      canvas.restore();
      canvas.save();
  }

  @override
  void update(double t) {
    components.addAll(_addLater);
    _addLater.clear();

    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
  }

  @override
  void resize(Size size) {
    this.size = size;
    components.forEach((c) => c.resize(size));
  }

  double currentTime() {
    return new DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
  }
}
