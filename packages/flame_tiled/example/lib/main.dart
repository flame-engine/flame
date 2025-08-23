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

class ScrollSnowComponent extends Component {
  ScrollSnowComponent();
  double _elapsed = 0;

  @override
  void update(double dt) {
    if (parent is! RenderableLayer || parent == null) {
      return;
    }

    final p = parent! as RenderableLayer;
    _elapsed += dt;

    p
      ..offsetX -= sin(_elapsed * 0.5) * 3.0
      ..offsetY += 1 + sin(_elapsed).abs();
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
      'map.tmx',
      Vector2.all(16),
    );
    await world.add(mapComponent);

    final snowLayer = mapComponent.tileMap.getRenderableLayer(
      'Snow',
    );

    // This layer is toggled to scroll infinitely across both
    // the x and y axis. Add a component to apply real-time
    // scrolling behavior to make the snow fall!
    if (snowLayer != null) {
      await snowLayer.add(ScrollSnowComponent());
    }

    final objectGroup = mapComponent.tileMap.getLayer<ObjectGroup>(
      'AnimatedCoins',
    );

    // No coins to add. No work to be done.
    if (objectGroup == null) {
      return;
    }

    final coins = await Flame.images.load('coins.png');

    // Add sprites behind the ground decoration layer.
    final groundLayer = mapComponent.tileMap.getRenderableLayer('Ground');

    for (final object in objectGroup.objects) {
      groundLayer?.add(
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
