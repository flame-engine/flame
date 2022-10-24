import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_svg/svg.dart';

/// Wraps [Svg] in a Flame component.
class SvgComponent extends PositionComponent with HasPaint {
  /// The wrapped instance of [Svg].
  Svg? _svg;

  /// Creates an [SvgComponent]
  SvgComponent({
    Svg? svg,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    Paint? paint,
  }) : _svg = svg {
    this.paint = paint ?? this.paint;
  }

  set svg(Svg? svg) {
    _svg?.dispose();
    _svg = svg;
  }

  /// Returns the current [svg] instance
  Svg? get svg => _svg;

  @override
  void render(Canvas canvas) {
    _svg?.render(canvas, size, overridePaint: paint);
  }

  @override
  void onRemove() {
    super.onRemove();

    _svg?.dispose();
  }
}
