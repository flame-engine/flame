import 'package:EmberQuest/main.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/rendering.dart';

class CloudComponent extends ParallaxComponent<EmberQuestGame> {
  CloudComponent() : super(priority: -1);

  @override
  Future<void> onLoad() async {
    final cloud1Image = await gameRef.images.load('cloud1.png');
    final cloud2Image = await gameRef.images.load('cloud2.png');
    parallax = Parallax([
      ParallaxLayer(
        ParallaxImage(
          cloud1Image,
          fill: LayerFill.none,
          alignment: Alignment.topLeft,
        ),
        velocityMultiplier: Vector2(1.0, 0.0),
      ),
      ParallaxLayer(
        ParallaxImage(
          cloud2Image,
          fill: LayerFill.none,
          alignment: Alignment.topLeft,
        ),
        velocityMultiplier: Vector2(0.2, 0.0),
      ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    parallax?.baseVelocity.x = 5.0;
  }
}
