import 'package:examples/stories/games/trex/background/cloud.dart';
import 'package:examples/stories/games/trex/random_extension.dart';
import 'package:examples/stories/games/trex/trex_game.dart';
import 'package:flame/components.dart';

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
    final numClouds = children.length;
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
