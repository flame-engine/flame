import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_svg/svg.dart';

/// Wraps [Svg] in a Flame component.
class SvgComponent({
  /// The wrapped instance of [Svg].
  var Svg? _svg,
  super.position,
  super.size,
  super.scale,
  super.angle,
  super.anchor,
  super.children,
  super.priority,
  Paint? paint,
  super.key,
}) extends PositionComponent with HasPaint {
  /// Creates an [SvgComponent]
  this {
    this.paint = paint ?? (this.paint..filterQuality = FilterQuality.medium);
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
