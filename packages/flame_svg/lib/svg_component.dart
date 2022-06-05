import 'dart:ui';

import 'package:flame/components.dart';

import 'package:flame_svg/svg.dart';

/// Wraps [Svg] in a Flame component.
class SvgComponent extends PositionComponent {
  /// The wrapped instance of [Svg].
  Svg? _svg;

  /// Creates an [SvgComponent]
  SvgComponent({
    Svg? svg,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  })  : _svg = svg,
        super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
        );

  /// Creates an [SvgComponent] from an [Svg] instance.
  @Deprecated(
    'Will be removed in flame_svg v1.2.0, use the default constructor instead',
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

  /// Sets a new [svg] instance
  set svg(Svg? svg) {
    _svg?.dispose();
    _svg = svg;
  }

  /// Returns the current [svg] instance
  Svg? get svg => _svg;

  @override
  void render(Canvas canvas) {
    _svg?.render(canvas, size);
  }

  @override
  void onRemove() {
    super.onRemove();

    _svg?.dispose();
  }
}
