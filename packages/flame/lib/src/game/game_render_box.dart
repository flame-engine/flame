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

  int _updateTime = 0;
  int _renderTime = 0;
  bool _trackPerformance = false;
  Stopwatch? _stopwatch;

  /// The time it took to update the game in milliseconds.
  int get updateTime => _updateTime;

  /// The time it took to render the game in milliseconds.
  int get renderTime => _renderTime;

  /// Whether or not to track the performance of the game.
  bool get trackPerformance => _trackPerformance;
  set trackPerformance(bool value) {
    if (_trackPerformance == value) {
      return;
    }
    _trackPerformance = value;

    if (_trackPerformance) {
      _stopwatch = Stopwatch();
    } else {
      _stopwatch?.stop();
      _stopwatch = null;
    }
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

    _stopwatch?.reset();
    _stopwatch?.start();

    game.update(dt);

    _stopwatch?.stop();
    _updateTime = _stopwatch?.elapsedMilliseconds ?? 0;

    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

    _stopwatch?.reset();
    _stopwatch?.start();

    game.render(context.canvas);

    _stopwatch?.stop();
    _renderTime = _stopwatch?.elapsedMilliseconds ?? 0;

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
}
