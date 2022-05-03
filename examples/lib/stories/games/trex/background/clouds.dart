import 'package:flame/components.dart';

import '../random_extension.dart';
import '../trex_game.dart';

class Cloud extends SpriteComponent {
  Cloud({required Vector2 position})
      : cloudGap = random.fromRange(
          minCloudGap,
          maxCloudGap,
        ),
        super(
          position: position,
          size: initialSize,
          sprite: Sprite(
            TRexGame.spriteImage,
            srcPosition: Vector2(166.0, 2.0),
            srcSize: initialSize,
          ),
        );

  static Vector2 initialSize = Vector2(92.0, 28.0);

  static const double maxCloudGap = 400.0;
  static const double minCloudGap = 100.0;

  static const double maxSkyLevel = 71.0;
  static const double minSkyLevel = 30.0;

  final double cloudGap;

  @override
  void update(double dt) {
    super.update(dt);
    if (shouldRemove) {
      return;
    }
    x -= (parent as CloudManager).cloudSpeed.ceil() * 50 * dt;

    if (!isVisible) {
      removeFromParent();
    }
  }

  bool get isVisible {
    return x + width > 0;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    y = ((absolutePosition.y / 2 - (maxSkyLevel - minSkyLevel)) +
            random.fromRange(minSkyLevel, maxSkyLevel)) -
        absolutePositionOf(absoluteTopLeftPosition).y;
  }
}

class CloudManager extends PositionComponent with HasGameRef<TRexGame> {
  final double cloudFrequency = 0.5;
  final int maxClouds = 20;
  final double bgCloudSpeed = 0.2;

  void addCloud() {
    final cloudPosition = Vector2(
      gameRef.size.x + Cloud.initialSize.x + 10,
      ((absolutePosition.y / 2 - (Cloud.maxSkyLevel - Cloud.minSkyLevel)) +
              random.fromRange(Cloud.minSkyLevel, Cloud.maxSkyLevel)) -
          absolutePosition.y,
    );
    add(Cloud(position: cloudPosition));
  }

  double get cloudSpeed => bgCloudSpeed / 1000 * gameRef.currentSpeed;

  @override
  void update(double dt) {
    super.update(dt);
    final int numClouds = children.length;
    if (numClouds > 0) {
      final lastCloud = children.last as Cloud;
      if (numClouds < maxClouds &&
          (gameRef.size.x / 2 - lastCloud.x) > lastCloud.cloudGap) {
        addCloud();
      }
    } else {
      addCloud();
    }
  }

  void reset() {
    removeAll(children);
  }
}
