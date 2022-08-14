import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
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
            SequenceEffect(
              [
                RotateEffect.by(
                  pi * 2,
                  LinearEffectController(.4),
                ),
                RotateEffect.by(
                  0,
                  LinearEffectController(.4),
                ),
              ],
              infinite: true,
            ),
          ],
        );
}

class ClipComponentExample extends FlameGame {
  static String description = '';

  @override
  Future<void> onLoad() async {
    addAll(
      [
        CircleClipComponent(
          position: Vector2(100, 100),
          size: Vector2.all(50),
          children: [_Rectangle()],
        ),
        RectangleClipComponent(
          position: Vector2(200, 100),
          size: Vector2.all(50),
          children: [_Rectangle()],
        ),
        PolygonClipComponent(
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
}
