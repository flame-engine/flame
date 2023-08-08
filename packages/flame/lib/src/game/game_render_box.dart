import 'package:flame/game.dart';
import 'package:flame/src/game/game_loop.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;

/// A [RenderObjectWidget] that renders the [GameRenderBox].
///
/// This is the widget that is used by the [GameWidget] to ACTUALLY
/// render the game.
class RenderGameWidget extends LeafRenderObjectWidget {
  const RenderGameWidget({
    required this.game,
    required this.addRepaintBoundary,
    super.key,
  });

  final Game game;
  final bool addRepaintBoundary;

  @override
  RenderBox createRenderObject(BuildContext context) {
    return GameRenderBox(game, context, isRepaintBoundary: addRepaintBoundary);
  }

  @override
  void updateRenderObject(BuildContext context, GameRenderBox renderObject) {
    renderObject
      ..game = game
      ..buildContext = context
      ..isRepaintBoundary = addRepaintBoundary;
  }
}

class GameRenderBox extends RenderBox with WidgetsBindingObserver {
  GameRenderBox(
    this._game,
    this.buildContext, {
    required bool isRepaintBoundary,
  }) : _isRepaintBoundary = isRepaintBoundary;

  GameLoop? gameLoop;

  BuildContext buildContext;

  Game _game;

  Game get game => _game;

  set game(Game value) {
    // Identities are equal, no need to update.
    if (_game == value) {
      return;
    }

    if (attached) {
      _detachGame();
    }

    _game = value;

    if (attached) {
      _attachGame(owner!);
    }
  }

  bool _isRepaintBoundary;

  set isRepaintBoundary(bool value) {
    if (_isRepaintBoundary == value) {
      return;
    }
    _isRepaintBoundary = value;
    markNeedsCompositingBitsUpdate();
  }

  @override
  bool get isRepaintBoundary => _isRepaintBoundary;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _attachGame(owner);
  }

  void _attachGame(PipelineOwner owner) {
    game.attach(owner, this);

    final gameLoop = this.gameLoop = GameLoop(gameLoopCallback);

    if (!game.paused) {
      gameLoop.start();
    }

    _bindLifecycleListener();
  }

  @override
  void detach() {
    super.detach();
    _detachGame();
  }

  void _detachGame() {
    game.detach();
    gameLoop?.dispose();
    gameLoop = null;
    _unbindLifecycleListener();
  }

  void gameLoopCallback(double dt) {
    assert(attached);
    if (!attached) {
      return;
    }
    game.update(dt);
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    game.render(context.canvas);
    context.canvas.restore();
  }

  void _bindLifecycleListener() {
    WidgetsBinding.instance.addObserver(this);
    didChangeAppLifecycleState(
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
    );
  }

  void _unbindLifecycleListener() {
    WidgetsBinding.instance.removeObserver(this);
    didChangeAppLifecycleState(AppLifecycleState.paused);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    game.lifecycleStateChange(state);
  }
}
