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
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  /// Creates an [SvgComponent] from an [Svg] instance.
  @Deprecated(
    'Will be removed on future versions, use the default '
    'constructor instead',
  )
  SvgComponent.fromSvg(
    Svg svg, {
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : this(
          svg: svg,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  @override
  void render(Canvas canvas) {
    svg?.render(canvas, size);
  }
}
