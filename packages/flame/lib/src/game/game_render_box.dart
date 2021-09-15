import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;

import '../extensions/size.dart';
import 'game_loop.dart';
import 'mixins/game.dart';

// ignore: prefer_mixin
class GameRenderBox extends RenderBox with WidgetsBindingObserver {
  BuildContext buildContext;
  Game game;
  GameLoop? gameLoop;

  GameRenderBox(this.buildContext, this.game) {
    WidgetsBinding.instance!.addTimingsCallback(game.onTimingsCallback);
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void performResize() {
    super.performResize();
    game.onGameResize(constraints.biggest.toVector2());
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    game.attach(owner, this);

    final gameLoop = this.gameLoop = GameLoop(gameLoopCallback);

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
    game.onRemove();
    game.detach();
    gameLoop?.dispose();
    gameLoop = null;
    _unbindLifecycleListener();
  }

  void gameLoopCallback(double dt) {
    if (!attached) {
      return;
    }
    game.update(dt);
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    game.render(context.canvas);
    context.canvas.restore();
  }

  void _bindLifecycleListener() {
    WidgetsBinding.instance!.addObserver(this);
  }

  void _unbindLifecycleListener() {
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    game.lifecycleStateChange(state);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;
}
