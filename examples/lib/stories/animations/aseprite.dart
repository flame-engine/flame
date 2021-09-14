import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Aseprite extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final image = await images.load('animations/chopper.png');
    final jsonData = await assets.readJson('images/animations/chopper.json');
    final animation = SpriteAnimation.fromAsepriteData(image, jsonData);
    final spriteSize = Vector2.all(200);
    final animationComponent = SpriteAnimationComponent(
      animation: animation,
      position: (size - spriteSize) / 2,
      size: spriteSize,
    );
    add(animationComponent);
  }
}
