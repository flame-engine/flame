import 'dart:ui';

import 'components/component.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

abstract class BaseGameWidget extends GameWidget {

  final List<Component> components = new List();

  @override
  bool destroy() {
    return false;
  }

  @override
  bool loaded() {
    return true;
  }

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
  final Component component;

  GameRenderObjectWidget(this.component);

  @override
  RenderObject createRenderObject(BuildContext ctx) => new GameRenderBox(ctx, this.component);
}

class GameRenderBox extends RenderBox {
  BuildContext context;

  Component component;

  int _frameCallbackId;

  Duration previous = Duration.ZERO;

  GameRenderBox(this.context, this.component);

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
    component.update(_computeDeltaT(now));
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
    component.render(context.canvas);
  }
}
