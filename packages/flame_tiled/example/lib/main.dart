import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;
import 'package:tiled/tiled.dart' show ObjectGroup, TmxObject;
import 'package:flame_tiled/flame_tiled.dart';

void main() {
  runApp(GameWidget(game: TiledGame()));
}

class TiledGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final tiledMap = await TiledComponent.load('map.tmx', Vector2.all(16));
    add(tiledMap);
    final objGroup =
        tiledMap.renderableTiledMap.getObjectGroupFromLayer('AnimatedCoins');
    for (final obj in objGroup.objects) {
      final comp = SpriteAnimationComponent(
        position: Vector2.all(20),
        animation: SpriteAnimation.fromFrameData(
          await Flame.images.load('coins.png'),
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: .15,
            textureSize: Vector2.all(20),
          ),
        ),
      );
      comp.x = obj.x.toDouble();
      comp.y = obj.y.toDouble();
      add(comp);
    }
  }
}
