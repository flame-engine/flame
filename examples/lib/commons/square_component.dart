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
          Vector2.all(size),
          position: position,
          paint: paint,
          priority: priority,
        );
}
