import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:trex_game/background/cloud_manager.dart';
import 'package:trex_game/obstacle/obstacle_manager.dart';
import 'package:trex_game/trex_game.dart';

class Horizon extends PositionComponent with HasGameReference<TRexGame> {
  Horizon() : super();

  static final Vector2 lineSize = Vector2(1200, 24);
  final Queue<SpriteComponent> groundLayers = Queue();
  late final CloudManager cloudManager = CloudManager();
  late final ObstacleManager obstacleManager = ObstacleManager();

  late final _softSprite = Sprite(
    game.spriteImage,
    srcPosition: Vector2(2.0, 104.0),
    srcSize: lineSize,
  );

  late final _bumpySprite = Sprite(
    game.spriteImage,
    srcPosition: Vector2(game.spriteImage.width / 2, 104.0),
    srcSize: lineSize,
  );

  @override
  Future<void> onLoad() async {
    add(cloudManager);
    add(obstacleManager);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final increment = game.currentSpeed * dt;
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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final newLines = _generateLines();
    groundLayers.addAll(newLines);
    addAll(newLines);
    y = (size.y / 2) + 21.0;
  }

  void reset() {
    cloudManager.reset();
    obstacleManager.reset();
    groundLayers.forEachIndexed((i, line) => line.x = i * lineSize.x);
  }

  List<SpriteComponent> _generateLines() {
    final number = 1 + (game.size.x / lineSize.x).ceil() - groundLayers.length;
    final lastX = (groundLayers.lastOrNull?.x ?? 0) +
        (groundLayers.lastOrNull?.width ?? 0);
    return List.generate(
      max(number, 0),
      (i) => SpriteComponent(
        sprite: (i + groundLayers.length).isEven ? _softSprite : _bumpySprite,
        size: lineSize,
      )..x = lastX + lineSize.x * i,
      growable: false,
    );
  }
}
