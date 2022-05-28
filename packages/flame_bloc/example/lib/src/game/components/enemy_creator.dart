import 'dart:math';

import 'package:flame/components.dart';

import 'package:flame_bloc_example/src/game/components/enemy.dart';
import 'package:flame_bloc_example/src/game/game.dart';

class EnemyCreator extends TimerComponent with HasGameRef<SpaceShooterGame> {
  Random random = Random();

  EnemyCreator() : super(period: 1, repeat: true);

  @override
  void onTick() {
    gameRef.add(
      EnemyComponent(
        (gameRef.size.x - 25) * random.nextDouble(),
        0,
      ),
    );
  }
}
