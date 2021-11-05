import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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

class SimpleShapes extends FlameGame with HasTappableComponents {
  final _rng = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.zoom = 2;
  }

  MyShapeComponent randomShape(Vector2 position) {
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
    final shapeSize =
        Vector2.all(25) + Vector2.all(50.0).scaled(_rng.nextDouble());
    final shapeAngle = _rng.nextDouble() * 6;
    switch (shapeType) {
      case Shapes.circle:
        return MyShapeComponent(
          HitboxCircle(),
          position: position,
          size: shapeSize,
          angle: shapeAngle,
        );
      case Shapes.rectangle:
        return MyShapeComponent(
          HitboxRectangle(),
          position: position,
          size: shapeSize,
          angle: shapeAngle,
        );
      case Shapes.polygon:
        final points = [
          Vector2.random(_rng),
          Vector2.random(_rng)..y *= -1,
          -Vector2.random(_rng),
          Vector2.random(_rng)..x *= -1,
        ];
        return MyShapeComponent(
          HitboxPolygon(points),
          position: position,
          size: shapeSize,
          angle: shapeAngle,
        );
    }
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    final tapDownPoint = info.eventPosition.game;
    final component = randomShape(tapDownPoint);
    add(component);
    //component.add(MoveEffect(
    //  path: [size / 2],
    //  speed: 30,
    //  isAlternating: true,
    //  isInfinite: true,
    //));
    component.add(RotateEffect(
      angle: 3,
      speed: 0.4,
      isAlternating: true,
      isInfinite: true,
    ));
  }
}

class MyShapeComponent extends ShapeComponent with Tappable {
  @override
  final Paint paint = BasicPalette.red.paint()..style = PaintingStyle.stroke;

  MyShapeComponent(
    HitboxShape shape, {
    Vector2? position,
    Vector2? size,
    double? angle,
  }) : super(
          shape,
          position: position,
          size: size,
          angle: angle,
        );

  @override
  bool onTapDown(TapDownInfo _) {
    removeFromParent();
    return true;
  }
}
