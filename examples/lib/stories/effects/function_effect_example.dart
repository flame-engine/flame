import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

enum RobotState {
  idle,
  running,
}

class FunctionEffectExample extends FlameGame with TapDetector {
  static const String description = '''
This example shows how to use the FunctionEffect to create custom effects.

The robot will switch between running and idle animations over the duration of
10 seconds.
''';

  @override
  Future<void> onLoad() async {
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

    final functionEffect =
        FunctionEffect<SpriteAnimationGroupComponent<RobotState>>(
          (target, progress) {
            if (progress > 0.7) {
              target.current = RobotState.idle;
            } else if (progress > 0.3) {
              target.current = RobotState.running;
            }
          },
          EffectController(duration: 10.0, infinite: true),
        );
    final component = SpriteAnimationGroupComponent<RobotState>(
      animations: {
        RobotState.running: running,
        RobotState.idle: idle,
      },
      current: RobotState.idle,
      position: size / 2,
      anchor: Anchor.center,
      size: robotSize,
      children: [functionEffect],
    );

    add(component);
  }
}
