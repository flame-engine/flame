import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/src/effects2/remove_effect.dart'; // ignore: implementation_imports
import 'package:flutter/material.dart';
import '../../commons/circle_component.dart';

class RemoveEffectExample extends FlameGame with HasTappableComponents {
  static const description = '''
    Click on any circle to apply a RemoveEffect, which will make the circle
    disappear after a 0.5 second delay.
  ''';

  @override
  void onMount() {
    super.onMount();
    camera.viewport = FixedResolutionViewport(Vector2(400, 600));
    final rng = Random();
    for (var i = 0; i < 20; i++) {
      add(_RandomCircle(rng));
    }
  }
}

class _RandomCircle extends CircleComponent with Tappable {
  _RandomCircle(Random rng) : super(radius: rng.nextDouble() * 30 + 10) {
    position.setValues(
      rng.nextDouble() * 320 + 40,
      rng.nextDouble() * 520 + 40,
    );
    paint.color = Colors.primaries[rng.nextInt(Colors.primaries.length)];
  }

  @override
  bool onTapDown(TapDownInfo info) {
    add(RemoveEffect(delay: 0.5));
    return false;
  }
}
