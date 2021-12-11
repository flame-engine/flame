import 'package:flame/extensions.dart';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/material.dart';

import '../component/timer_component.dart';
import '../component/velocity_component.dart';
import '../main.dart';

class MoveSystem extends System with UpdateSystem, GameRef<ExampleGame> {
  Query? _query;

  @override
  void init() {
    _query = createQuery([
      Has<PositionComponent>(),
      Has<VelocityComponent>(),
    ]);
  }

  @override
  void dispose() {
    _query = null;
    super.dispose();
  }

  @override
  void update(double delta) {
    for (final entity in _query?.entities ?? <Entity>[]) {
      final velocity = entity.get<VelocityComponent>()!.velocity;
      final size = entity.get<SizeComponent>()!.size;
      final position = entity.get<PositionComponent>()!.position
        ..add(velocity * delta);

      final screenSize = Vector2.zero() & game!.size;
      if (!screenSize.containsPoint(position) ||
          !screenSize.containsPoint(position + size)) {
        velocity.setFrom(-velocity);

        game!.createEntity(
          name: '${entity.name} says',
          position: position + size / 2,
          size: Vector2.zero(),
          anchor: Anchor.topCenter,
        )
          ..add<TextComponent, TextInit>(
            TextInit(
              'Kawabunga',
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
          )
          ..add<TimerComponent, double>(3);
      }
    }
  }
}
