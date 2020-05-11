import 'dart:ui' show Canvas;

import '../svg.dart';
import 'position_component.dart';

/// A [PositionComponent] that renders a single [Svg] at the designated position,
/// scaled to have the designated size and rotated to the designated angle.
///
/// This is the simplest way to add an SVG to the game.
class SvgComponent extends PositionComponent {
  Svg svg;

  SvgComponent.fromSvg(double width, double height, this.svg) {
    this.width = width;
    this.height = height;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    svg.render(canvas, width, height);
  }

  @override
  bool loaded() {
    return svg != null && svg.loaded() && x != null && y != null;
  }
}
