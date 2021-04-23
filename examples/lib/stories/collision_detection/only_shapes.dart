import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

class OnlyShapes extends BaseGame with TapDetector {
  final shapes = List<Shape>.empty(growable: true);
  final myPaint = BasicPalette.red.paint()..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    shapes.forEach((shape) => shape.render(canvas, myPaint));
  }

  @override
  void onTapDown(TapDownInfo event) {
    final tapDownPoint = event.eventPosition.game;
    final shape = shapes.firstWhere(
        (shape) => shape.containsPoint(tapDownPoint),
        orElse: () => Circle(radius: 20, position: tapDownPoint));
    if (shapes.contains(shape)) {
      shapes.remove(shape);
    } else {
      shapes.add(shape);
    }
  }
}
