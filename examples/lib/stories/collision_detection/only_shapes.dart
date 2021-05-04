import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

enum Shapes { circle, rectangle, polygon }

class OnlyShapes extends BaseGame with HasTapableComponents {
  final shapePaint = BasicPalette.red.paint()..style = PaintingStyle.stroke;
  final _rng = Random();

  Shape randomShape(Vector2 position) {
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
    const size = 50.0;
    switch (shapeType) {
      case Shapes.circle:
        return Circle(radius: size / 2, position: position);
      case Shapes.rectangle:
        return Rectangle(
          position: position,
          size: Vector2.all(size),
          angle: _rng.nextDouble() * 6,
        );
      case Shapes.polygon:
        final points = [
          Vector2.random(_rng),
          Vector2.random(_rng)..y *= -1,
          -Vector2.random(_rng),
          Vector2.random(_rng)..x *= -1,
        ];
        return Polygon.fromDefinition(
          points,
          position: position,
          size: Vector2.all(size),
          angle: _rng.nextDouble() * 6,
        );
    }
  }

  @override
  void onTapDown(int pointerId, TapDownInfo event) {
    super.onTapDown(pointerId, event);
    final tapDownPoint = event.eventPosition.game;
    final component = MyShapeComponent(randomShape(tapDownPoint), shapePaint);
    add(component);
  }
}

class MyShapeComponent extends ShapeComponent with Tapable {
  MyShapeComponent(Shape shape, Paint shapePaint) : super(shape, shapePaint);

  @override
  bool onTapDown(TapDownInfo event) {
    remove();
    return true;
  }
}
