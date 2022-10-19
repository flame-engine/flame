import 'package:EmberQuest/actors/ember.dart';
import 'package:EmberQuest/actors/water_enemy.dart';
import 'package:EmberQuest/managers/segment_manager.dart';
import 'package:EmberQuest/objects/ground_block.dart';
import 'package:EmberQuest/objects/platform_block.dart';
import 'package:EmberQuest/objects/star.dart';
import 'package:EmberQuest/overlays/hud.dart';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  EmberQuestGame();

  late EmberPlayer _ember;
  late double lastBlockXPosition = 0.0;
  late GlobalKey lastBlockKey;

  int starsCollected = 0;
  int health = 3;
  double cloudSpeed = 0.0;
  double objectSpeed = 0.0;

  @override
  Future<void> onLoad() async {
    //debugMode = true; //Uncomment to see the bounding boxes
    initializeGame(true);
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
    }
    super.update(dt);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (var block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          add(GroundBlock(
            gridPosition: block.gridPosition,
            xPositionOffset: xPositionOffset,
          ));
          break;
        case PlatformBlock:
          add(PlatformBlock(
            gridPosition: block.gridPosition,
            xPositionOffset: xPositionOffset,
          ));
          break;
        case Star:
          add(Star(
            gridPosition: block.gridPosition,
            xPositionOffset: xPositionOffset,
          ));
          break;
        case WaterEnemy:
          add(WaterEnemy(
            gridPosition: block.gridPosition,
            xPositionOffset: xPositionOffset,
          ));
          break;
      }
    }
  }

  initializeGame(bool loadHud) {
    //Assume that size.x < 3200
    int segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, 4);

    segmentsToLoad = 2;

    for (int i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }

    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 70),
    );
    add(_ember);
    if (loadHud) {
      add(Hud());
    }
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(false);
  }
}
