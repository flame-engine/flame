import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;
import 'package:tiled/tiled.dart';

void main() {
  runApp(GameWidget(game: TiledGame()));
}

class TiledGame extends FlameGame {
  late TiledComponent mapComponent;

  double time = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    mapComponent =
        await TiledComponent.load('map.tmx', Vector2.all(16), camera: camera);
    add(mapComponent);

    final objGroup =
        mapComponent.tileMap.getLayer<ObjectGroup>('AnimatedCoins');
    final coins = await Flame.images.load('coins.png');

    camera.viewport = FixedResolutionViewport(Vector2(16 * 28, 16 * 14));

    // We are 100% sure that an object layer named `AnimatedCoins`
    // exists in the example `map.tmx`.
    for (final obj in objGroup!.objects) {
      add(
        SpriteAnimationComponent(
          size: Vector2.all(20.0),
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

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    final tiledMap = mapComponent.tileMap.map;
    if (time % 10 < 5) {
      camera.moveTo(Vector2(
          tiledMap.width * tiledMap.tileWidth.toDouble() -
              camera.viewport.effectiveSize.x,
          camera.viewport.effectiveSize.y));
    } else {
      camera.moveTo(Vector2(0, 0));
    }
  }
}
