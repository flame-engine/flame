import 'package:flame/components.dart';
import 'package:trex_game/background/cloud_manager.dart';
import 'package:trex_game/random_extension.dart';
import 'package:trex_game/trex_game.dart';

class Cloud extends SpriteComponent
    with ParentIsA<CloudManager>, HasGameReference<TRexGame> {
  Cloud({required Vector2 position})
      : cloudGap = random.fromRange(
          minCloudGap,
          maxCloudGap,
        ),
        super(
          position: position,
          size: initialSize,
        );

  static final Vector2 initialSize = Vector2(92.0, 28.0);

  static const double maxCloudGap = 400.0;
  static const double minCloudGap = 100.0;

  static const double maxSkyLevel = 71.0;
  static const double minSkyLevel = 30.0;

  final double cloudGap;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.spriteImage,
      srcPosition: Vector2(166.0, 2.0),
      srcSize: initialSize,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isRemoving) {
      return;
    }
    x -= parent.cloudSpeed.ceil() * 50 * dt;

    if (!isVisible) {
      removeFromParent();
    }
  }

  bool get isVisible {
    return x + width > 0;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    y = ((absolutePosition.y / 2 - (maxSkyLevel - minSkyLevel)) +
            random.fromRange(minSkyLevel, maxSkyLevel)) -
        absolutePositionOf(absoluteTopLeftPosition).y;
  }
}
