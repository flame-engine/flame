import 'package:flame/components.dart';
import 'package:flame/game.dart';

class JoystickPlayer extends SpriteComponent with HasGameRef {
  static const speed = 16.0;

  final JoystickComponent joystick;

  double currentSpeed = 0;

  JoystickPlayer(this.joystick)
      : super(
          size: Vector2.all(50.0),
        ) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load('flame.png');
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!joystick.delta.isZero()) {
      position.add(joystick.delta * speed * dt);
      angle = joystick.delta.screenAngle();
    }
  }
}
