import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:trex_game/background/cloud_manager.dart';
import 'package:trex_game/obstacle/obstacle_manager.dart';
import 'package:trex_game/trex_game.dart';

class Horizon extends PositionComponent with HasGameRef<TRexGame> {
  Horizon() : super();

  static final Vector2 lineSize = Vector2(1200, 24);
  final Queue<SpriteComponentDarkOnSecondary> groundLayers = Queue();
  late final Moon moon = Moon()..y = -90;
  late final HorizonBlocker horizonBlocker = HorizonBlocker()..y = 20;
  late final CloudManager cloudManager = CloudManager();
  late final ObstacleManager obstacleManager = ObstacleManager();

  late final _softSprite = Sprite(
    gameRef.spriteImage,
    srcPosition: Vector2(2.0, 104.0),
    srcSize: lineSize,
  );

  late final _bumpySprite = Sprite(
    gameRef.spriteImage,
    srcPosition: Vector2(gameRef.spriteImage.width / 2, 104.0),
    srcSize: lineSize,
  );

  @override
  Future<void> onLoad() async {
    add(moon);
    add(horizonBlocker);
    add(cloudManager);
    add(obstacleManager);
  }

  void stop() {
    moon.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final increment = gameRef.currentSpeed * dt;
    for (final line in groundLayers) {
      line.x -= increment;
    }

    final firstLine = groundLayers.first;
    if (firstLine.x <= -firstLine.width) {
      firstLine.x = groundLayers.last.x + groundLayers.last.width;
      groundLayers.remove(firstLine);
      groundLayers.add(firstLine);
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    final newLines = _generateLines();
    groundLayers.addAll(newLines);
    addAll(newLines);
    y = (gameSize.y / 2) + 21.0;

    horizonBlocker.size = Vector2(gameSize.x, y + 0);
  }

  void reset() {
    cloudManager.reset();
    obstacleManager.reset();
    groundLayers.forEachIndexed((i, line) => line.x = i * lineSize.x);
    moon.reset();
  }

  List<SpriteComponentDarkOnSecondary> _generateLines() {
    final number =
        1 + (gameRef.size.x / lineSize.x).ceil() - groundLayers.length;
    final lastX = (groundLayers.lastOrNull?.x ?? 0) +
        (groundLayers.lastOrNull?.width ?? 0);
    return List.generate(
      max(number, 0),
      (i) {
        final sp = SpriteComponentDarkOnSecondary(
          sprite: (i + groundLayers.length).isEven ? _softSprite : _bumpySprite,
          size: lineSize,
          priority: 5,
        )..x = lastX + lineSize.x * i;

        return sp;
      },
      growable: false,
    );
  }
}

class Moon extends CircleComponent with HasGameRef<TRexGame> {
  Moon() : super(radius: 150, anchor: Anchor.center, priority: 0);

  final EffectController _effectController = EffectController(
    duration: 60,
  );

  late final effect = MoveToEffect(
    Vector2(game.player.absoluteCenter.x, y),
    _effectController,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    x = game.size.x * 0.9;
  }

  void reset() {
    x = game.size.x * 0.9;
    add(effect);
    _effectController.setToStart();
  }

  void stop() {
    effect.removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (canvas is CanvasSecondary) {
      super.render(canvas);
    }
  }
}

class HorizonBlocker extends RectangleComponent {
  HorizonBlocker() : super(priority: 1000);

  @override
  late final Paint paint = Paint()..color = const Color(0xFF000000);

  @override
  void render(Canvas canvas) {
    if (canvas is CanvasSecondary) {
      super.render(canvas);
    }
  }
}
