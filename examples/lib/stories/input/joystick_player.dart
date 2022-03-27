import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class JoystickPlayer extends SpriteComponent
    with HasGameRef, CollisionCallbacks {
  /// Pixels/s
  double maxSpeed = 300.0;
  late final Vector2 _lastPosition = position.clone();
  late double _lastAngle = angle;

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
      _lastPosition.setFrom(position);
      position.add(joystick.relativeDelta * maxSpeed * dt);
      _lastAngle = angle;
      angle = joystick.delta.screenAngle();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> _, PositionComponent __) {
    super.onCollisionStart(_, __);
    position.setFrom(_lastPosition);
    angle = _lastAngle;
  }

  @override
  void onCollisionEnd(PositionComponent __) {
    super.onCollisionEnd(__);
  }
}
