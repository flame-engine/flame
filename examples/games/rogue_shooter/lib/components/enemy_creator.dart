import 'dart:math';

import 'package:flame/components.dart';
import 'package:rogue_shooter/components/enemy_component.dart';

class EnemyCreator extends TimerComponent with HasGameRef {
  final Random random = Random();
  final _halfWidth = EnemyComponent.initialSize.x / 2;

  EnemyCreator() : super(period: 0.05, repeat: true);

  @override
  void onTick() {
    game.addAll(
      List.generate(
        5,
        (index) => EnemyComponent(
          position: Vector2(
            _halfWidth + (game.size.x - _halfWidth) * random.nextDouble(),
            0,
          ),
        ),
      ),
    );
  }
}
