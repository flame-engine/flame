import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
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
    mapComponent = await TiledComponent.load('map.tmx', Vector2.all(16));
    world.add(mapComponent);

    // Create a camera-panning sequence across the 4 corners
    // of the map
    camera.viewfinder.add(
      SequenceEffect(
        [
          for (int i = 0, j = 0; j < 2; i++, j = i ~/ 2)
            MoveToEffect(
              Vector2(
                mapComponent.width * min(1, i % 3),
                mapComponent.height * j,
              ),
              EffectController(
                duration: 3,
              ),
            ),
        ],
        alternate: true,
        alternatePattern: AlternatePattern.doNotRepeatLast,
        infinite: true,
      ),
    );

    camera.setBounds(
      Rectangle.fromLTRB(0, 0, mapComponent.width, mapComponent.height),
      considerViewport: true,
    );

    final objectGroup =
        mapComponent.tileMap.getLayer<ObjectGroup>('AnimatedCoins');
    final coins = await Flame.images.load('coins.png');

    // We are 100% sure that an object layer named `AnimatedCoins`
    // exists in the example `map.tmx`.
    for (final object in objectGroup!.objects) {
      world.add(
        SpriteAnimationComponent(
          size: Vector2.all(20.0),
          position: Vector2(object.x, object.y),
          animation: SpriteAnimation.fromFrameData(
            coins,
            SpriteAnimationData.sequenced(
              amount: 8,
              stepTime: 0.15,
              textureSize: Vector2.all(20),
            ),
          ),
        ),
      );
    }
  }
}
