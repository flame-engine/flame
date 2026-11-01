import 'package:flame/components.dart' as flame;
import 'package:flame_studio/component_editor/widgets/preview/dashed_outline.dart';
import 'package:flutter/painting.dart';

/// {@template preview_position_component}
/// The Flame component that previews a position component.
///
/// A `PositionComponent` draws nothing itself, so the preview outlines it
/// with a faint dashed line, letting users see it while it isn't selected.
/// The outline only exists in the preview: the generated code uses a plain
/// `PositionComponent`.
/// {@endtemplate}
class PreviewPositionComponent() extends flame.PositionComponent {
  /// {@macro preview_position_component}
  this;

  /// The color of the outline.
  static const color = Color(0x66FFFFFF);

  static final _paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    drawDashedPolygon(canvas, [
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ], _paint);
  }
}
