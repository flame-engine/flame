import 'dart:math';

import 'package:flame/components.dart';

import 'package:flame_bloc_example/src/game/components/enemy.dart';
import 'package:flame_bloc_example/src/game/game.dart';

class EnemyCreator extends TimerComponent
    with HasGameReference<SpaceShooterGame> {
  Random random = Random();

  EnemyCreator() : super(period: 1, repeat: true);

  @override
  void onTick() {
    game.add(
      EnemyComponent(
        (game.size.x - 25) * random.nextDouble(),
        0,
      ),
    );
  }
}
