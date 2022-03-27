import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class JoystickPlayer extends SpriteComponent
    with HasGameRef, CollisionCallbacks {
  /// Pixels/s
  double maxSpeed = 300.0;
  late final Vector2 _lastSize = size.clone();
  late final Transform2D _lastTransform = transform.clone();

  final JoystickComponent joystick;

  JoystickPlayer(this.joystick)
      : super(size: Vector2.all(100.0), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('layers/player.png');
    position = gameRef.size / 2;
    add(RectangleHitbox()..debugMode = true);
  }

  @override
  void update(double dt) {
    if (!joystick.delta.isZero() && activeCollisions.isEmpty) {
      _lastSize.setFrom(size);
      _lastTransform.setFrom(transform);
      position.add(joystick.relativeDelta * maxSpeed * dt);
      angle = joystick.delta.screenAngle();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> _, PositionComponent __) {
    super.onCollisionStart(_, __);
    transform.setFrom(_lastTransform);
    size.setFrom(_lastSize);
  }

  @override
  void onCollisionEnd(PositionComponent __) {
    super.onCollisionEnd(__);
  }
}
