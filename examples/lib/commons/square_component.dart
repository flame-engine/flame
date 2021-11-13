import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class SquareComponent extends RectangleComponent with EffectsHelper {
  SquareComponent({
    Vector2? position,
    double size = 100.0,
    Paint? paint,
    int priority = 0,
  }) : super(
          position: position,
          size: Vector2.all(size),
          paint: paint,
          priority: priority,
        );
}
