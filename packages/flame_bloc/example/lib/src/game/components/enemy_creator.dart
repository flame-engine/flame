import 'dart:math';

import 'package:flame/components.dart';

import './enemy.dart';
import '../game.dart';

class EnemyCreator extends TimerComponent with HasGameRef<SpaceShooterGame> {
  Random random = Random();

  EnemyCreator() : super(limit: 1, repeat: true, autoStart: true);

  @override
  void tick() {
    gameRef.add(
      EnemyComponent(
        (gameRef.size.x - 25) * random.nextDouble(),
        0,
      ),
    );
  }
}
