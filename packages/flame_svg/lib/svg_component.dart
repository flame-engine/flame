import 'dart:ui';

import 'package:flame/components.dart';

import './svg.dart';

class SvgComponent extends PositionComponent {
  Svg svg;

  SvgComponent.fromSvg(
    this.svg, {
    Vector2? position,
    Vector2? size,
    int? priority,
  }) : super(position: position, size: size, priority: priority);

  @override
  void render(Canvas canvas) {
    svg.render(canvas, size);
  }
}
