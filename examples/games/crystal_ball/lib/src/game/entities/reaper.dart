import 'package:crystal_ball/src/game/constants.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Reaper extends PositionComponent with HasGameReference<CrystalBallGame> {
  Reaper()
      : super(
          position: Vector2(0, 0),
          size: Vector2(kCameraSize.x * 2, 100),
          anchor: Anchor.topCenter,
          children: [
            RectangleHitbox(),
          ],
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y = game.world.cameraTarget.position.y +
        (kCameraSize.y + kReaperTolerance) / 2;
  }
}
