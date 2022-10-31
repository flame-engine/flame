import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;

void main() {
  runApp(GameWidget(game: TiledGame()));
}

class TiledGame extends FlameGame {
  late TiledComponent mapComponent;

  double time = 0;
  Vector2 cameraTarget = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    mapComponent = await TiledComponent.load('map.tmx', Vector2.all(16));
    add(mapComponent);

    final objGroup =
        mapComponent.tileMap.getLayer<ObjectGroup>('AnimatedCoins');
    final coins = await Flame.images.load('coins.png');

    camera.zoom = 0.5;
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
    // Pan the camera down and right for 10 seconds, then reverse
    if (time % 20 < 10) {
      cameraTarget.x = tiledMap.width * tiledMap.tileWidth.toDouble() -
          camera.viewport.effectiveSize.x;
      cameraTarget.y = camera.viewport.effectiveSize.y;
    } else {
      cameraTarget.setZero();
    }
    camera.moveTo(cameraTarget);
  }
}
