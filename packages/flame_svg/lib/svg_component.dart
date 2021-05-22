import 'package:flame/components.dart';

import 'dart:ui';

import './svg.dart';

class SvgComponent extends PositionComponent {
  Svg svg;

  SvgComponent.fromSvg(this.svg, {Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    svg.render(canvas, size);
  }
}
