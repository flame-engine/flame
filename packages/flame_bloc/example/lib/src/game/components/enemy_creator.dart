import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/timer.dart';

import './enemy.dart';
import '../game.dart';

class EnemyCreator extends Component with HasGameRef<SpaceShooterGame> {
  late Timer enemyCreator;

  Random random = Random();

  EnemyCreator() {
    enemyCreator = Timer(
      1,
      repeat: true,
      callback: () {
        gameRef.add(
          EnemyComponent(
            (gameRef.size.x - 25) * random.nextDouble(),
            0,
          ),
        );
      },
    );
    enemyCreator.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    enemyCreator.update(dt);
  }
}
