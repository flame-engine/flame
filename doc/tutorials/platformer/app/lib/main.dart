import 'package:EmberQuest/actors/ember.dart';
import 'package:EmberQuest/actors/water_enemy.dart';
import 'package:EmberQuest/objects/clouds.dart';
import 'package:EmberQuest/objects/ground.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  final game = EmberQuestGame();
  runApp(GameWidget(game: game));
}

class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasTappables {
  EmberQuestGame();

  late final EmberPlayer _ember;

  @override
  Future<void> onLoad() async {
    //debugMode = true; //Uncomment to see the bounding boxes
/*     camera.viewport = FixedResolutionViewport(
      Vector2(1536, 768),
    );
 */
    await add(
      GroundComponent(),
    );
    await add(
      CloudComponent(),
    );
    _ember = EmberPlayer(
      position: Vector2(canvasSize.x / 2, canvasSize.y - 128),
    );
    add(_ember);

    add(
      WaterEnemy(
        position: Vector2(canvasSize.x - 100, canvasSize.y - 128),
      ),
    );
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}
