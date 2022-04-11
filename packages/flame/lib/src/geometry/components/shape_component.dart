
import 'dart:ui';


import 'package:vector_math/vector_math_64.dart';

import '../shapes/shape.dart';

import '../../components/position_component.dart';

class ShapeComponent extends PositionComponent {
  ShapeComponent(this.shape, {
    this.backgroundPaint,
    this.borderPaint,
    Vector2? position,
  }) : super(position: position, );

  final Shape shape;
  final Paint? backgroundPaint;
  final Paint? borderPaint;

}
