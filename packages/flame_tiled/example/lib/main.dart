import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart' hide Animation, Image;

void main() {
  runApp(GameWidget(game: TiledGame()));
}

/// Scrolls the layer that it is added to, which makes the repeating snow
/// image layer of the example map fall.
class SnowScroller extends Component with ParentIsA<RenderableLayer> {
  double _elapsed = 0;

  @override
  void update(double dt) {
    _elapsed += dt;
    parent
      ..offsetX -= sin(_elapsed * 0.5) * 180 * dt
      ..offsetY += (60 + 60 * sin(_elapsed).abs()) * dt;
  }
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
          Vector2(180, 90),
          EffectController(
            duration: 5,
            alternate: true,
            infinite: true,
          ),
        ),
      );

    mapComponent = await TiledComponent.load(
      'assets/tiles/map.tmx',
      Vector2.all(16),
    );
    world.add(mapComponent);

    // The snow layer repeats infinitely on both axes, so scrolling it makes
    // the snow fall over the whole map.
    mapComponent.tileMap.getRenderableLayer('Snow')?.add(SnowScroller());

    final objectGroup = mapComponent.tileMap.getLayer<ObjectGroup>(
      'AnimatedCoins',
    );
    final coins = await Flame.images.load('assets/images/coins.png');

    // The coins are added to the ground layer, so that they are rendered on
    // top of the ground but underneath the ground decoration layer.
    final groundLayer = mapComponent.tileMap.getRenderableLayer('Ground');

    // We are 100% sure that an object layer named `AnimatedCoins` and a
    // tile layer named `Ground` exist in the example `map.tmx`.
    for (final object in objectGroup!.objects) {
      groundLayer!.add(
        SpriteAnimationComponent(
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
        ),
      );
    }
  }
}
