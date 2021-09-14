import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

const onlyShapesInfo = '''
An example which adds random shapes on the screen when you tap it, if you tap on
an already existing shape it will remove that shape and replace it with a new
one.
''';

enum Shapes { circle, rectangle, polygon }

class OnlyShapes extends FlameGame with HasTappableComponents {
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
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    final tapDownPoint = info.eventPosition.game;
    final component = MyShapeComponent(randomShape(tapDownPoint), shapePaint);
    add(component);
  }
}

class MyShapeComponent extends ShapeComponent with Tappable {
  MyShapeComponent(Shape shape, Paint shapePaint)
      : super(
          shape,
          shapePaint,
          anchor: Anchor.center,
        );

  @override
  bool onTapDown(TapDownInfo info) {
    removeFromParent();
    return true;
  }
}
