import 'dart:ui';

import 'package:flame/components.dart';

import './svg.dart';

/// Wraps [Svg] in a Flame component.
class SvgComponent extends PositionComponent {
  /// The wrapped instance of [Svg].
  Svg? svg;

  /// Creates an [SvgComponent]
  SvgComponent({
    this.svg,
    Vector2? position,
    Vector2? size,
    int? priority,
  }) : super(position: position, size: size, priority: priority);

  /// Creates an [SvgComponent] from an [Svg] instance.
  SvgComponent.fromSvg(
    Svg svg, {
    Vector2? position,
    Vector2? size,
    int? priority,
  }) : this(svg: svg, position: position, size: size, priority: priority);

  @override
  void render(Canvas canvas) {
    svg?.render(canvas, size);
  }
}
