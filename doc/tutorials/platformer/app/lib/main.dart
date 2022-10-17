import 'package:EmberQuest/actors/ember.dart';
import 'package:EmberQuest/actors/water_enemy.dart';
import 'package:EmberQuest/managers/segment_manager.dart';
import 'package:EmberQuest/objects/ground_block.dart';
import 'package:EmberQuest/objects/platform_block.dart';
import 'package:EmberQuest/objects/star.dart';
import 'package:flame/collisions.dart';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  final game = EmberQuestGame();
  runApp(GameWidget(game: game));
}

class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  EmberQuestGame();

  late final EmberPlayer _ember;
  double currentSpeed = 0.0;

  @override
  Future<void> onLoad() async {
    //debugMode = true; //Uncomment to see the bounding boxes
    add(ScreenHitbox());
    int segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, 4);

    for (int i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i);
    }

    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 70),
    );
    add(_ember);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void loadGameSegments(int segmentIndex) {
    for (var block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          add(GroundBlock(
            gridPosition: block.gridPosition,
            segmentOffset: segmentIndex,
          ));
          break;
        case PlatformBlock:
          add(PlatformBlock(
            gridPosition: block.gridPosition,
            segmentOffset: segmentIndex,
          ));
          break;
        case Star:
          add(Star(
            gridPosition: block.gridPosition,
            segmentOffset: segmentIndex,
          ));
          break;
      }
    }
  }
}
