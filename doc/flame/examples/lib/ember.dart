import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';

class EmberPlayer extends SpriteAnimationComponent with TapCallbacks {
  EmberPlayer({
    required super.position,
    required super.size,
    void Function(EmberPlayer)? onTap,
  })  : _onTap = onTap,
        super();

  Vector2 velocity = Vector2(0, 0);
  final void Function(EmberPlayer)? _onTap;

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      await Flame.images.load('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );

    add(CircleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    position += velocity * dt;
    super.update(dt);
  }

  @override
  void onTapUp([TapUpEvent? event]) => _onTap?.call(this);
}
