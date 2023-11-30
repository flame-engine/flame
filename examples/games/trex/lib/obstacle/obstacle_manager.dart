import 'dart:collection';

import 'package:flame/components.dart';
import 'package:trex_game/obstacle/obstacle.dart';
import 'package:trex_game/obstacle/obstacle_type.dart';
import 'package:trex_game/random_extension.dart';
import 'package:trex_game/trex_game.dart';

class ObstacleManager extends Component with HasGameReference<TRexGame> {
  ObstacleManager();

  ListQueue<ObstacleType> history = ListQueue();
  static const int maxObstacleDuplication = 2;

  @override
  void update(double dt) {
    final obstacles = children.query<Obstacle>();

    if (obstacles.isNotEmpty) {
      final lastObstacle = children.last as Obstacle?;

      if (lastObstacle != null &&
          !lastObstacle.followingObstacleCreated &&
          lastObstacle.isVisible &&
          (lastObstacle.x + lastObstacle.width + lastObstacle.gap) <
              game.size.x) {
        addNewObstacle();
        lastObstacle.followingObstacleCreated = true;
      }
    } else {
      addNewObstacle();
    }
  }

  void addNewObstacle() {
    final speed = game.currentSpeed;
    if (speed == 0) {
      return;
    }
    var settings = random.nextBool()
        ? ObstacleTypeSettings.cactusSmall
        : ObstacleTypeSettings.cactusLarge;
    if (duplicateObstacleCheck(settings.type) || speed < settings.allowedAt) {
      settings = ObstacleTypeSettings.cactusSmall;
    }

    final groupSize = _groupSize(settings);
    for (var i = 0; i < groupSize; i++) {
      add(Obstacle(settings: settings, groupIndex: i));
      game.score++;
    }

    history.addFirst(settings.type);
    while (history.length > maxObstacleDuplication) {
      history.removeLast();
    }
  }

  bool duplicateObstacleCheck(ObstacleType nextType) {
    var duplicateCount = 0;

    for (final type in history) {
      duplicateCount += type == nextType ? 1 : 0;
    }
    return duplicateCount >= maxObstacleDuplication;
  }

  void reset() {
    removeAll(children);
    history.clear();
  }

  int _groupSize(ObstacleTypeSettings settings) {
    if (game.currentSpeed > settings.multipleAt) {
      return random.fromRange(1.0, ObstacleTypeSettings.maxGroupSize).floor();
    } else {
      return 1;
    }
  }
}
