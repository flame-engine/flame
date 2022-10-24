import 'dart:math';

import 'package:collision_detection_performance/components/enemy_component.dart';
import 'package:flame/components.dart';

class EnemyCreator extends TimerComponent with HasGameRef {
  final Random random = Random();
  final _halfWidth = EnemyComponent.initialSize.x / 2;

  EnemyCreator() : super(period: 0.05, repeat: true);

  @override
  void onTick() {
    gameRef.addAll(
      List.generate(
        5,
        (index) => EnemyComponent(
          position: Vector2(
            _halfWidth + (gameRef.size.x - _halfWidth) * random.nextDouble(),
            0,
          ),
        ),
      ),
    );
  }
}
