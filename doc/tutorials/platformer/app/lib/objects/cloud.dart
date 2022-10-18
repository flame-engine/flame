import 'package:EmberQuest/ember_quest.dart';
import 'package:EmberQuest/extensions/random.dart';
import 'package:EmberQuest/managers/cloud_manager.dart';
import 'package:flame/components.dart';

class Cloud extends SpriteComponent
    with ParentIsA<CloudManager>, HasGameRef<EmberQuestGame> {
  Cloud({required Vector2 position})
      : cloudGap = random.fromRange(
          minCloudGap,
          maxCloudGap,
        ),
        super(
          position: position,
          size: initialSize,
        );

  static Vector2 initialSize = Vector2(92.0, 28.0);

  static const double maxCloudGap = 400.0;
  static const double minCloudGap = 100.0;

  static const double maxSkyLevel = 71.0;
  static const double minSkyLevel = 30.0;

  final double cloudGap;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      await gameRef.images.load('cloud1.png'),
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
