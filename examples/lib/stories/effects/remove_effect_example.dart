import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class RemoveEffectExample extends FlameGame {
  static const description = '''
    Click on any circle to apply a RemoveEffect, which will make the circle
    disappear after a 0.5 second delay.
  ''';

  final world = World();
  late final CameraComponent cameraComponent;

  @override
  void onLoad() {
    super.onMount();
    cameraComponent = CameraComponent.withFixedResolution(
      world: world,
      width: 400,
      height: 600,
    );
    cameraComponent.viewfinder.anchor = Anchor.topLeft;
    addAll([cameraComponent, world]);
    final rng = Random();
    for (var i = 0; i < 20; i++) {
      world.add(_RandomCircle.random(rng));
    }
  }
}

class _RandomCircle extends CircleComponent with TapCallbacks {
  _RandomCircle(double radius, {super.position, super.paint})
      : super(radius: radius);

  factory _RandomCircle.random(Random rng) {
    final radius = rng.nextDouble() * 30 + 10;
    final position = Vector2(
      rng.nextDouble() * 320 + 40,
      rng.nextDouble() * 520 + 40,
    );
    final paint = Paint()
      ..color = Colors.primaries[rng.nextInt(Colors.primaries.length)];
    return _RandomCircle(radius, position: position, paint: paint);
  }

  @override
  void onTapDown(TapDownEvent info) {
    add(RemoveEffect(delay: 0.5));
  }
}
