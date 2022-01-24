import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';

class Ember<T extends FlameGame> extends SpriteAnimationComponent
    with HasGameRef<T> {
  Ember({Vector2? position, Vector2? size, int? priority})
      : super(
          position: position,
          size: size ?? Vector2.all(50),
          priority: priority,
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
