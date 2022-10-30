import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';

class Ember<T extends FlameGame> extends SpriteAnimationComponent
    with HasGameRef<T> {
  Ember({super.position, Vector2? size, super.priority})
      : super(
          size: size ?? Vector2.all(50),
          anchor: Anchor.center,
        );

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'animations/ember.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: Vector2.all(16),
        stepTime: 0.15,
      ),
    );
  }
}
