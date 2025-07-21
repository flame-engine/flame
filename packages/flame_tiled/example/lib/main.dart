import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;

void main() {
  runApp(GameWidget(game: TiledGame()));
}

class TiledGame extends FlameGame {
  late TiledComponent mapComponent;

  TiledGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 16 * 28,
            height: 16 * 14,
          ),
        );

  @override
  Future<void> onLoad() async {
    camera.viewfinder
      ..zoom = 0.5
      ..anchor = Anchor.topLeft
      ..add(
        MoveToEffect(
          Vector2(320, 180),
          EffectController(
            duration: 10,
            alternate: true,
            infinite: true,
          ),
        ),
      );

    mapComponent = await TiledComponent.load('map.tmx', Vector2.all(16));
    world.add(mapComponent);

    final objectGroup =
        mapComponent.tileMap.getLayer<ObjectGroup>('AnimatedCoins');
    final coins = await Flame.images.load('coins.png');

    // Add sprites behind the ground decoration layer.
    final groundLayer = mapComponent.tileMap.getRenderableLayer('Ground');

    // We are 100% sure that an object layer named `AnimatedCoins`
    // exists in the example `map.tmx`.
    for (final object in objectGroup!.objects) {
      final sprite = SpriteAnimationComponent(
        size: Vector2.all(20.0),
        anchor: Anchor.center,
        position: Vector2(object.x, object.y),
        animation: SpriteAnimation.fromFrameData(
          coins,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.15,
            textureSize: Vector2.all(20),
          ),
        ),
      );
      groundLayer?.add(sprite);
    }
  }
}
