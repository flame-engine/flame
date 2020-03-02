import 'package:flame/components/tiled_component.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flutter/widgets.dart' hide Animation;
import 'package:tiled/tiled.dart' show ObjectGroup, TmxObject;

void main() {
  Flame.images.load('coins.png');
  final TiledGame game = TiledGame();
  runApp(game.widget);
}

class TiledGame extends BaseGame {
  TiledGame() {
    final TiledComponent tiledMap = TiledComponent('map.tmx');
    add(tiledMap);
    _addCoinsInMap(tiledMap);
  }

  void _addCoinsInMap(TiledComponent tiledMap) async {
    final ObjectGroup obj =
        await tiledMap.getObjectGroupFromLayer("AnimatedCoins");
    if (obj == null) {
      return;
    }
    for (TmxObject obj in obj.tmxObjects) {
      final comp = AnimationComponent(
          Animation.fromImage(
              Flame.images.fromCache('coins.png'),
              frameCount: 8,
              frameWidth: 20
          ),
          height: 20.0,
          width: 20.0,
      );
      comp.x = obj.x.toDouble();
      comp.y = obj.y.toDouble();
      add(comp);
    }
  }
}
