import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Gradient;

class _Rectangle extends RectangleComponent {
  _Rectangle()
      : super(
          size: Vector2(200, 200),
          anchor: Anchor.center,
          paint: Paint()
            ..shader = Gradient.linear(
              Offset.zero,
              const Offset(0, 100),
              [Colors.orange, Colors.blue],
            ),
          children: [
            RotateEffect.by(
              pi * 2,
              EffectController(duration: .4, infinite: true),
            ),
          ],
        );
}

class ClipComponentExample extends FlameGame with TapDetector {
  static const String description =
      'Tap on the objects to increase their size.';

  @override
  Future<void> onLoad() async {
    addAll(
      [
        ClipComponent.circle(
          position: Vector2(100, 100),
          size: Vector2.all(50),
          children: [_Rectangle()],
        ),
        ClipComponent.rectangle(
          position: Vector2(200, 100),
          size: Vector2.all(50),
          children: [_Rectangle()],
        ),
        ClipComponent.polygon(
          points: [
            Vector2(1, 0),
            Vector2(1, 1),
            Vector2(0, 1),
            Vector2(1, 0),
          ],
          position: Vector2(200, 200),
          size: Vector2.all(50),
          children: [_Rectangle()],
        ),
      ],
    );
  }

  @override
  void onTapUp(TapUpInfo info) {
    final position = info.eventPosition.widget;
    final hit = children
        .whereType<PositionComponent>()
        .where(
          (component) => component.containsLocalPoint(
            position - component.position,
          ),
        )
        .toList();

    hit.forEach((component) {
      component.size += Vector2.all(10);
    });
  }
}
