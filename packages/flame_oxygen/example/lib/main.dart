import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flame_oxygen_example/component/timer_component.dart';
import 'package:flame_oxygen_example/component/velocity_component.dart';
import 'package:flame_oxygen_example/system/debug_system.dart';
import 'package:flame_oxygen_example/system/kawabunga_system.dart';
import 'package:flame_oxygen_example/system/move_system.dart';
import 'package:flame_oxygen_example/system/sprite_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: ExampleGame()));
}

class ExampleGame extends OxygenGame {
  @override
  Future<void> init() async {
    if (kDebugMode) {
      world.registerSystem(DebugSystem());
    }
    world.registerSystem(MoveSystem());
    world.registerSystem(SpriteSystem());
    world.registerSystem(KawabungaSystem());

    world.registerComponent<TimerComponent, double>(TimerComponent.new);
    world.registerComponent<VelocityComponent, Vector2>(
      VelocityComponent.new,
    );

    final random = Random();
    for (var i = 0; i < 10; i++) {
      createEntity(
        name: 'Entity $i',
        position: size / 2,
        size: Vector2.all(64),
        angle: 0,
      )
        ..add<SpriteComponent, SpriteInit>(
          SpriteInit(await loadSprite('pizza.png')),
        )
        ..add<VelocityComponent, Vector2>(
          Vector2(
            random.nextDouble() * 100 * (random.nextBool() ? 1 : -1),
            random.nextDouble() * 100 * (random.nextBool() ? 1 : -1),
          ),
        );
    }
  }
}
