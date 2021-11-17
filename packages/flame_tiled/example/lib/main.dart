import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;

void main() {
  runApp(GameWidget(game: TiledGame()));
}

class TiledGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final tiledMap = await TiledComponent.load('map.tmx', Vector2.all(16));
    add(tiledMap);

    final objGroup = tiledMap.tileMap.getObjectGroupFromLayer('AnimatedCoins');
    final coins = await Flame.images.load('coins.png');
    for (final obj in objGroup.objects) {
      add(
        SpriteAnimationComponent(
          position: Vector2(obj.x, obj.y),
          animation: SpriteAnimation.fromFrameData(
            coins,
            SpriteAnimationData.sequenced(
              amount: 8,
              stepTime: .15,
              textureSize: Vector2.all(20),
            ),
          ),
        ),
      );
    }
  }
}
