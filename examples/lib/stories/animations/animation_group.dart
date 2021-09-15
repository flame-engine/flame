import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

enum RobotState {
  idle,
  running,
}

class AnimationGroupExample extends FlameGame with TapDetector {
  late SpriteAnimationGroupComponent robot;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final running = await loadSpriteAnimation(
      'animations/robot.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.2,
        textureSize: Vector2(16, 18),
      ),
    );
    final idle = await loadSpriteAnimation(
      'animations/robot-idle.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.4,
        textureSize: Vector2(16, 18),
      ),
    );

    final robotSize = Vector2(64, 72);
    robot = SpriteAnimationGroupComponent<RobotState>(
      animations: {
        RobotState.running: running,
        RobotState.idle: idle,
      },
      current: RobotState.idle,
      position: size / 2 - robotSize / 2,
      size: robotSize,
    );

    add(robot);
  }

  @override
  void onTapDown(_) {
    robot.current = RobotState.running;
  }

  @override
  void onTapCancel() {
    robot.current = RobotState.idle;
  }

  @override
  void onTapUp(_) {
    robot.current = RobotState.idle;
  }

  @override
  Color backgroundColor() => const Color(0xFF222222);
}
