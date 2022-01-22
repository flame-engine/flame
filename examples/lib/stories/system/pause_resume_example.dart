import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class PauseResumeExample extends FlameGame with TapDetector, DoubleTapDetector {
  static const description = '''
    Demonstrate how to use the pause and resume engine methods and paused
    attribute.

    Tap on the screen to toggle the execution of the engine using the
    `resumeEngine` and `pauseEngine`.

    Double Tap on the screen to toggle the execution of the engine using the
    `paused` attribute.
  ''';

  @override
  Future<void> onLoad() async {
    final animation = await loadSpriteAnimation(
      'animations/chopper.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );

    add(
      SpriteAnimationComponent(
        animation: animation,
      )
        ..position = size / 2
        ..anchor = Anchor.center
        ..size = Vector2.all(100),
    );
  }

  @override
  void onTap() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }

  @override
  void onDoubleTap() {
    paused = !paused;
  }
}
