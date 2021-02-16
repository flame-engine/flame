import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;

import 'game.dart';
import 'game_loop.dart';

class GameRenderBox extends RenderBox with WidgetsBindingObserver {
  BuildContext context;
  Game game;
  GameLoop gameLoop;

  GameRenderBox(this.context, this.game) {
    gameLoop = GameLoop(gameLoopCallback);
    WidgetsBinding.instance.addTimingsCallback(game.onTimingsCallback);
  }

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
    game.onAttach();

    game.pauseEngineFn = gameLoop.pause;
    game.resumeEngineFn = gameLoop.resume;

    if (game.runOnCreation) {
      gameLoop.start();
    }

    _bindLifecycleListener();
  }

  @override
  void detach() {
    super.detach();
    game.onDetach();
    gameLoop.stop();
    _unbindLifecycleListener();
  }

  void gameLoopCallback(double dt) {
    if (!attached) {
      return;
    }
    // ignore: deprecated_member_use_from_same_package
    game.recordDt(dt);
    game.update(dt);
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(
        game.builder.offset.dx + offset.dx, game.builder.offset.dy + offset.dy);
    game.render(context.canvas);
    context.canvas.restore();
  }

  void _bindLifecycleListener() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _unbindLifecycleListener() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    game.lifecycleStateChange(state);
  }

  // TODO(luan): this was added to flutter beta but pub is still using an old version to lint
  // in this state it will work for all flutter channels until stable catches up
  // ignore: annotate_overrides
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;
}
