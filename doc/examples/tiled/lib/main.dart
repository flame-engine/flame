import 'package:flame/components/tiled_component.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flame/animation.dart';
import 'package:flutter/widgets.dart' hide Animation;
import 'package:tiled/tiled.dart' show ObjectGroup, TmxObject;

void main() {
  Flame.images.load('coins.png');
  final TiledGame game = TiledGame();
  runApp(game.widget);
}

class TiledGame extends BaseGame {
  TiledComponent tiledMap;
  Animation a;
  TiledGame() {
    tiledMap = TiledComponent('map.tmx');
    add(tiledMap);
    a = Animation.sequenced('coins.png', 8, textureWidth: 20);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final ObjectGroup obj = tiledMap.getObjectLayerByName("AnimatedCoins");
    if (obj == null) {
      return;
    }
    for (TmxObject obj in obj.tmxObjects) {
      final Rect rect =
          Rect.fromLTWH(obj.x.toDouble(), obj.y.toDouble(), 30.0, 30.0);
      final position = Position(obj.x.toDouble(), obj.y.toDouble());
      a.getSprite().renderPosition(canvas, position);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    a.update(t);
  }
}
