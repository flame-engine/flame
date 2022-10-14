import 'package:EmberQuest/main.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

class GroundComponent extends ParallaxComponent<EmberQuestGame> {
  GroundComponent() : super(priority: -1);

  @override
  Future<void> onLoad() async {
    final groundImage = await gameRef.images.load('ground.png');
    parallax = Parallax([
      ParallaxLayer(
        ParallaxImage(
          groundImage,
          fill: LayerFill.none,
        ),
      )
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    parallax?.baseVelocity.x = 0;
  }
}
