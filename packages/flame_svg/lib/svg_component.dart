import 'dart:ui';

import 'package:flame/components.dart';

import './svg.dart';

/// Wraps a [Svg] into a Flame component.
class SvgComponent extends PositionComponent {
  /// [Svg] instance
  Svg svg;

  /// Creates a [SvgComponent] from a [Svg] instance.
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
