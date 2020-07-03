import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/tiled_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' hide Animation;
import 'package:tiled/tiled.dart' show ObjectGroup, TmxObject;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.images.load('coins.png');
  final TiledGame game = TiledGame();
  runApp(game.widget);
}

class TiledGame extends BaseGame {
  TiledGame() {
    final TiledComponent tiledMap = TiledComponent(
      'map.tmx',
      destTileSize: const Size(16.0, 16.0),
    );
    add(tiledMap);
    _addCoinsInMap(tiledMap);
  }

  void _addCoinsInMap(TiledComponent tiledMap) async {
    final ObjectGroup objGroup =
        await tiledMap.getObjectGroupFromLayer("AnimatedCoins");
    if (objGroup == null) {
      return;
    }
    objGroup.tmxObjects.forEach((TmxObject obj) {
      final comp = AnimationComponent(
        20.0,
        20.0,
        Animation.sequenced(
          'coins.png',
          8,
          textureWidth: 20,
          textureHeight: 20,
        ),
      );
      comp.x = obj.x.toDouble();
      comp.y = obj.y.toDouble();
      add(comp);
    });
  }
}
