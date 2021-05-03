import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

enum Shapes { circle, rectangle, polygon }

class OnlyShapes extends BaseGame with TapDetector {
  final shapes = List<Shape>.empty(growable: true);
  final myPaint = BasicPalette.red.paint()..style = PaintingStyle.stroke;
  final _rng = Random();

  OnlyShapes() {
    camera.zoom = 2.0;
  }

  Shape randomShape(Vector2 position) {
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
    const size = 50.0;
    switch (shapeType) {
      case Shapes.circle:
        return Circle(radius: size / 2, position: position, camera: camera);
      case Shapes.rectangle:
        return Rectangle(
          position: position,
          size: Vector2.all(size),
          angle: _rng.nextDouble() * 6,
          camera: camera,
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
          camera: camera,
        );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    shapes.forEach((shape) => shape.renderShape(canvas, myPaint));
  }

  @override
  void onTapDown(TapDownInfo event) {
    final tapDownPoint = event.eventPosition.game;
    final shapesToRemove = shapes.where((e) => e.containsPoint(tapDownPoint));
    if (shapesToRemove.isNotEmpty) {
      shapes.removeWhere(shapesToRemove.contains);
    } else {
      shapes.add(randomShape(tapDownPoint));
    }
  }
}
